//
//  ArtistTopTagsSectionDataSource.swift
//  LastFMNotifier
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

// TODO: handle case when there are no top tags (show a special cell)
class ArtistTopTagsSectionDataSource: ArtistSectionDataSource {
  private let viewModel: ArtistTopTagsSectionViewModel
  private let prototypeCell = TagCell()

  init(viewModel: ArtistTopTagsSectionViewModel) {
    self.viewModel = viewModel
  }

  var numberOfRows: Int {
    return viewModel.numberOfTopTags
  }

  func registerReusableViews(in collectionView: UICollectionView) {
    collectionView.register(TagCell.self, forCellWithReuseIdentifier: TagCell.reuseIdentifier)
    collectionView.register(ArtistSectionHeaderView.self,
                            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                            withReuseIdentifier: ArtistSectionHeaderView.reuseIdentifier)
  }

  func cellForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.reuseIdentifier,
                                                        for: indexPath) as? TagCell else {
      fatalError("TagCell is not registered in the collection view")
    }

    let cellViewModel = viewModel.cellViewModel(at: indexPath)
    cell.configure(with: cellViewModel)
    return cell
  }

  func sizeForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize {
    let cellViewModel = viewModel.cellViewModel(at: indexPath)
    return prototypeCell.size {
      self.prototypeCell.configure(with: cellViewModel)
    }
  }

  func viewForHeader(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionReusableView? {
    let reuseIdentifier = ArtistSectionHeaderView.reuseIdentifier
    guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                           withReuseIdentifier: reuseIdentifier,
                                                                           for: indexPath) as? ArtistSectionHeaderView else {
      return nil
    }

    headerView.configure(with: viewModel)
    return headerView
  }

  func sizeForHeader(inSection section: Int, in collectionView: UICollectionView) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 44)
  }

  func insetForSection(at index: Int, in collectionView: UICollectionView) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
  }
}
