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
    guard kind == UICollectionElementKindSectionHeader,
      let headerView = sectionDataSources[indexPath.section].viewForHeader(at: indexPath, in: collectionView) else {
      return UICollectionReusableView()
    }
    return headerView
  }

  func sizeForHeader(inSection section: Int, in collectionView: UICollectionView) -> CGSize {
    return sectionDataSources[section].sizeForHeader(inSection: section, in: collectionView)
  }

  func insetForSection(at index: Int, in collectionView: UICollectionView) -> UIEdgeInsets {
    return sectionDataSources[index].insetForSection(at: index, in: collectionView)
  }
}
