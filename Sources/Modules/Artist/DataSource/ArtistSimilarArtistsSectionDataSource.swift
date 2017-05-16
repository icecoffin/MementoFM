//
//  ArtistSimilarArtistsSectionDataSource.swift
//  LastFMNotifier
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistSimilarArtistsSectionDataSource: ArtistSectionDataSource {
  private let viewModel: ArtistSimilarArtistsSectionViewModel
  private let prototypeCell = SimilarArtistCell()
  var onDidUpdateData: (() -> Void)?

  init(viewModel: ArtistSimilarArtistsSectionViewModel) {
    self.viewModel = viewModel
    viewModel.didUpdateCellViewModels = { [weak self] in
      self?.onDidUpdateData?()
    }
  }

  var numberOfRows: Int {
    return viewModel.numberOfSimilarArtists
  }

  func registerReusableViews(in collectionView: UICollectionView) {
    collectionView.register(SimilarArtistCell.self, forCellWithReuseIdentifier: SimilarArtistCell.reuseIdentifier)
    collectionView.register(ArtistSectionHeaderView.self,
                            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                            withReuseIdentifier: ArtistSectionHeaderView.reuseIdentifier)
    collectionView.register(EmptyDataSetFooterView.self,
                            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                            withReuseIdentifier: EmptyDataSetFooterView.reuseIdentifier)
    collectionView.register(LoadingFooterView.self,
                            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                            withReuseIdentifier: LoadingFooterView.reuseIdentifier)
  }

  func cellForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimilarArtistCell.reuseIdentifier,
                                                        for: indexPath) as? SimilarArtistCell else {
                                                          fatalError("SimilarArtistCell is not registered in the collection view")
    }

    let cellViewModel = viewModel.cellViewModel(at: indexPath)
    cell.configure(with: cellViewModel)
    return cell
  }

  func sizeForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize {
    let cellViewModel = viewModel.cellViewModel(at: indexPath)
    return prototypeCell.size(constrainedToWidth: collectionView.frame.width) {
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
    if viewModel.isLoading {
      return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                             withReuseIdentifier: LoadingFooterView.reuseIdentifier,
                                                             for: indexPath)
    } else if !viewModel.hasSimilarArtists {
      let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                                   withReuseIdentifier: EmptyDataSetFooterView.reuseIdentifier,
                                                                   for: indexPath) as? EmptyDataSetFooterView
      footer?.configure(with: viewModel.emptyDataSetText)
      return footer
    }
    return nil
  }

  func sizeForFooter(inSection section: Int, in collectionView: UICollectionView) -> CGSize {
    if viewModel.isLoading {
      let prototypeFooter = LoadingFooterView()
      return prototypeFooter.size(constrainedToWidth: collectionView.frame.width)
    } else if !viewModel.hasSimilarArtists {
      let prototypeFooter = EmptyDataSetFooterView()
      return prototypeFooter.size(constrainedToWidth: collectionView.frame.width) {
        prototypeFooter.configure(with: self.viewModel.emptyDataSetText)
      }
    } else {
      return .zero
    }
  }
}
