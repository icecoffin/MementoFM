//
//  UICollectionViewLeftAlignedLayout.swift
//  MementoFM
//
//  Created by Dani on 07.04.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import UIKit

/// Swift rewrite of https://github.com/mokagio/UICollectionViewLeftAlignedLayout

final class UICollectionViewLeftAlignedLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originalAttributes = super.layoutAttributesForElements(in: rect) else { return nil }

        var updatedAttributes = originalAttributes
        for attributes in originalAttributes {
            if attributes.representedElementKind == nil,
               let index = updatedAttributes.firstIndex(of: attributes),
               let layoutAttributes = layoutAttributesForItem(at: attributes.indexPath) {
                updatedAttributes[index] = layoutAttributes
            }
        }

        return updatedAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }

        let currentItemAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        let sectionInset = evaluatedSectionInsetForItem(at: indexPath.section)

        let isFirstItemInSection = indexPath.item == 0
        let layoutWidth = collectionView.frame.width - sectionInset.left - sectionInset.right

        if isFirstItemInSection {
            currentItemAttributes?.leftAlignFrame(with: sectionInset)
            return currentItemAttributes
        }

        let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
        let previousFrame = layoutAttributesForItem(at: previousIndexPath)?.frame ?? .zero
        let previousFrameRightPoint = previousFrame.origin.x + previousFrame.width
        let currentFrame = currentItemAttributes?.frame ?? .zero
        let stretchedCurrentFrame = CGRect(
            x: sectionInset.left,
            y: currentFrame.origin.y,
            width: layoutWidth,
            height: currentFrame.height
        )
        // If the current frame, once left aligned to the left and stretched to the full collection view
        // width intersects the previous frame then they are on the same line
        let isFirstItemInRow = !previousFrame.intersects(stretchedCurrentFrame)
        if isFirstItemInRow {
            // Make sure the first item on a line is left aligned
            currentItemAttributes?.leftAlignFrame(with: sectionInset)
            return currentItemAttributes
        }

        let minimumInteritemSpacing = evaluatedMinimumInteritemSpacingForSection(at: indexPath.section)
        currentItemAttributes?.frame.origin.x = previousFrameRightPoint + minimumInteritemSpacing
        return currentItemAttributes
    }

    private func evaluatedMinimumInteritemSpacingForSection(at index: Int) -> CGFloat {
        guard let collectionView = self.collectionView else { return minimumInteritemSpacing }

        let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        return delegate?.collectionView?(
            collectionView,
            layout: self,
            minimumInteritemSpacingForSectionAt: index
        ) ?? minimumInteritemSpacing
    }

    private func evaluatedSectionInsetForItem(at index: Int) -> UIEdgeInsets {
        guard let collectionView = self.collectionView else { return sectionInset }

        let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        return delegate?.collectionView?(collectionView, layout: self, insetForSectionAt: index) ?? sectionInset
    }
}

private extension UICollectionViewLayoutAttributes {
    func leftAlignFrame(with sectionInset: UIEdgeInsets) {
        frame.origin.x = sectionInset.left
    }
}
