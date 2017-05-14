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

  init(viewModel: ArtistSimilarArtistsSectionViewModel) {
    self.viewModel = viewModel
  }

  var numberOfRows: Int {
    return viewModel.numberOfSimilarArtists
  }

  func registerReusableViews(in collectionView: UICollectionView) {
    collectionView.register(SimilarArtistCell.self, forCellWithReuseIdentifier: SimilarArtistCell.reuseIdentifier)
    collectionView.register(ArtistSectionHeaderView.self,
                            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                            withReuseIdentifier: ArtistSectionHeaderView.reuseIdentifier)
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
    return CGSize(width: collectionView.frame.width, height: 44)
  }
}
