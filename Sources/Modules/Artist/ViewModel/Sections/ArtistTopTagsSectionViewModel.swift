//
//  ArtistTopTagsSectionViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class ArtistTopTagsSectionViewModel: ArtistSectionViewModel {
  private let artist: Artist
  private let cellViewModels: [TagCellViewModel]

  required init(artist: Artist) {
    self.artist = artist
    cellViewModels = artist.topTags.map({ TagCellViewModel(tag: $0) })
  }

  var numberOfTopTags: Int {
    return cellViewModels.count
  }

  func cellViewModel(at indexPath: IndexPath) -> TagCellViewModel {
    return cellViewModels[indexPath.item]
  }

  var sectionHeaderText: String? {
    return "Top tags".unlocalized
  }
}
