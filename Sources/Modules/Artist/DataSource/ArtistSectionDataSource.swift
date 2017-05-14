//
//  ArtistSectionDataSource.swift
//  LastFMNotifier
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol ArtistSectionDataSource {
  var numberOfRows: Int { get }

  func registerReusableViews(in collectionView: UICollectionView)
  func cellForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell
  func sizeForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize

  func viewForHeader(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionReusableView?
  func sizeForHeader(inSection section: Int, in collectionView: UICollectionView) -> CGSize

  func insetForSection(at index: Int, in collectionView: UICollectionView) -> UIEdgeInsets
}

extension ArtistSectionDataSource {
  func viewForHeader(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionReusableView? {
    return nil
  }

  func sizeForHeader(inSection section: Int, in collectionView: UICollectionView) -> CGSize {
    return .zero
  }

  func insetForSection(at index: Int, in collectionView: UICollectionView) -> UIEdgeInsets {
    return .zero
  }
}
