//
//  ArtistTopTagsSectionViewModel.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol ArtistTopTagsSectionViewModelDelegate: class {
  func artistTopTagsSectionViewModel(_ viewModel: ArtistTopTagsSectionViewModel, didSelectTagWithName name: String)
}

final class ArtistTopTagsSectionViewModel {
  private let artist: Artist
  private let cellViewModels: [TagCellViewModel]

  weak var delegate: ArtistTopTagsSectionViewModelDelegate?

  required init(artist: Artist) {
    self.artist = artist
    cellViewModels = artist.topTags.map({ TagCellViewModel(tag: $0) })
  }

  var numberOfTopTags: Int {
    return cellViewModels.count
  }

  var hasTags: Bool {
    return !cellViewModels.isEmpty
  }

  func cellViewModel(at indexPath: IndexPath) -> TagCellViewModel {
    return cellViewModels[indexPath.item]
  }

  var sectionHeaderText: String? {
    return "Top tags".unlocalized
  }

  var emptyDataSetText: String {
    return "There are no tags for this artist.".unlocalized
  }

  func selectTag(withName name: String) {
    delegate?.artistTopTagsSectionViewModel(self, didSelectTagWithName: name)
  }
}
