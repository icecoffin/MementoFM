//
//  ArtistDataSource.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistDataSource {
  let sectionDataSources: [ArtistSectionDataSource]

  init(viewModel: ArtistViewModel) {
    sectionDataSources = viewModel.sectionDataSources
  }

  func registerReusableViews(in collectionView: UICollectionView) {
    sectionDataSources.forEach { $0.registerReusableViews(in: collectionView) }
    collectionView.register(EmptyDataSetFooterView.self,
                            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                            withReuseIdentifier: EmptyDataSetFooterView.reuseIdentifier)
  }

  var numberOfSections: Int {
    return sectionDataSources.count
  }

  func numberOfItems(inSection section: Int) -> Int {
    return sectionDataSources[section].numberOfRows
  }

  func cellForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
    return sectionDataSources[indexPath.section].cellForItem(at: indexPath, in: collectionView)
  }

  func sizeForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize {
    return sectionDataSources[indexPath.section].sizeForItem(at: indexPath, in: collectionView)
  }

  func supplementaryView(ofKind kind: String,
                         at indexPath: IndexPath,
                         in collectionView: UICollectionView) -> UICollectionReusableView {
    if kind == UICollectionElementKindSectionHeader {
      return sectionDataSources[indexPath.section].viewForHeader(at: indexPath, in: collectionView) ?? UICollectionReusableView()
    } else if kind == UICollectionElementKindSectionFooter {
      return sectionDataSources[indexPath.section].viewForFooter(at: indexPath, in: collectionView) ?? UICollectionReusableView()
    } else {
      fatalError("Unknown supplementary view kind")
    }
  }

  func sizeForHeader(inSection section: Int, in collectionView: UICollectionView) -> CGSize {
    return sectionDataSources[section].sizeForHeader(inSection: section, in: collectionView)
  }

  func sizeForFooter(inSection section: Int, in collectionView: UICollectionView) -> CGSize {
    return sectionDataSources[section].sizeForFooter(inSection: section, in: collectionView)
  }

  func insetForSection(at index: Int) -> UIEdgeInsets {
    return sectionDataSources[index].insetForSection(at: index)
  }

  func minimumLineSpacingForSection(at index: Int) -> CGFloat {
    return sectionDataSources[index].minimumLineSpacing
  }
}
