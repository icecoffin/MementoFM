//
//  ArtistSectionDataSource.swift
//  LastFMNotifier
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol ArtistSectionDataSource: class {
  var onDidUpdateData: (() -> Void)? { get set }

  var numberOfRows: Int { get }

  func registerReusableViews(in collectionView: UICollectionView)
  func cellForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell
  func sizeForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize

  func viewForHeader(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionReusableView?
  func sizeForHeader(inSection section: Int, in collectionView: UICollectionView) -> CGSize

  func viewForFooter(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionReusableView?
  func sizeForFooter(inSection section: Int, in collectionView: UICollectionView) -> CGSize

  func insetForSection(at index: Int) -> UIEdgeInsets
  var minimumLineSpacing: CGFloat { get }
}

extension ArtistSectionDataSource {
  func viewForHeader(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionReusableView? {
    return nil
  }

  func sizeForHeader(inSection section: Int, in collectionView: UICollectionView) -> CGSize {
    return .zero
  }

  func viewForFooter(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionReusableView? {
    return nil
  }

  func sizeForFooter(inSection section: Int, in collectionView: UICollectionView) -> CGSize {
    return .zero
  }

  func insetForSection(at index: Int) -> UIEdgeInsets {
    return .zero
  }

  var minimumLineSpacing: CGFloat {
    return 0
  }
}
