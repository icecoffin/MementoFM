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
    let prototypeHeader = ArtistSectionHeaderView()
    return prototypeHeader.size(constrainedToWidth: collectionView.frame.width) {
      prototypeHeader.configure(with: self.viewModel)
    }
  }

  func viewForFooter(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionReusableView? {
    let reuseIdentifier = EmptyDataSetFooterView.reuseIdentifier
    guard !viewModel.hasTags,
      let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                                       withReuseIdentifier: reuseIdentifier,
                                                                       for: indexPath) as? EmptyDataSetFooterView else {
      return nil
    }

    footerView.configure(with: viewModel.emptyDataSetText)
    return footerView
  }

  func sizeForFooter(inSection section: Int, in collectionView: UICollectionView) -> CGSize {
    if viewModel.hasTags {
      return .zero
    } else {
      let prototypeFooter = EmptyDataSetFooterView()
      return prototypeFooter.size(constrainedToWidth: collectionView.frame.width) {
        prototypeFooter.configure(with: self.viewModel.emptyDataSetText)
      }
    }
  }

  func insetForSection(at index: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
  }

  var minimumLineSpacing: CGFloat {
    return 8
  }
}
