//
//  ArtistInfoSectionDataSource.swift
//  LastFMNotifier
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistInfoSectionDataSource: ArtistSectionDataSource {
  private let viewModel: ArtistInfoSectionViewModel

  init(viewModel: ArtistInfoSectionViewModel) {
    self.viewModel = viewModel
  }

  var numberOfRows: Int {
    return 1
  }

  func registerReusableViews(in collectionView: UICollectionView) {
    collectionView.register(ArtistInfoCell.self, forCellWithReuseIdentifier: ArtistInfoCell.reuseIdentifier)
  }

  func cellForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistInfoCell.reuseIdentifier,
                                                        for: indexPath) as? ArtistInfoCell else {
      fatalError("ArtistInfoCell is not registered in the collection view")
    }

    let cellViewModel = viewModel.itemViewModel(at: indexPath.item)
    cell.configure(with: cellViewModel)
    return cell
  }

  func sizeForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize {
    let prototypeCell = ArtistInfoCell()
    return prototypeCell.size(constrainedToWidth: collectionView.frame.width)
  }
}
