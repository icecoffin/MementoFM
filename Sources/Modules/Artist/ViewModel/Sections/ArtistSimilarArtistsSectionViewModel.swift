//
//  ArtistSimilarArtistsSectionViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

class ArtistSimilarArtistsSectionViewModel: ArtistSectionViewModel {
  typealias Dependencies = HasRealmGateway

  private let artist: Artist
  private let dependencies: Dependencies

  private var cellViewModels: [SimilarArtistCellViewModel]
  private(set) var isLoading: Bool = true

  var didUpdateCellViewModels: (() -> Void)?

  required init(artist: Artist, dependencies: Dependencies) {
    self.artist = artist
    self.dependencies = dependencies
    self.cellViewModels = []
    calculateSimilarArtists()
  }

  var numberOfSimilarArtists: Int {
    return cellViewModels.count
  }

  var hasSimilarArtists: Bool {
    return !cellViewModels.isEmpty
  }

  var sectionHeaderText: String? {
    return "Similar artists".unlocalized
  }

  var emptyDataSetText: String {
    return "There are no similar artists.".unlocalized
  }

  func cellViewModel(at indexPath: IndexPath) -> SimilarArtistCellViewModel {
    return cellViewModels[indexPath.item]
  }

  private func calculateSimilarArtists() {
    dependencies.realmGateway.getArtistsWithIntersectingTopTags(for: artist).then { artists -> Void in
      self.createCellViewModels(from: artists)
    }.then(on: DispatchQueue.main) { _ -> Void in
      self.isLoading = false
      self.didUpdateCellViewModels?()
    }.noError()
  }

  // TODO: cleanup
  private func createCellViewModels(from artists: [Artist]) {
    cellViewModels = artists.map({ artist -> (Artist, Int) in
      let commonTags = self.artist.intersectingTopTagNames(with: artist)
      return (artist, commonTags.count)
    }).filter({ (_, commonTagsCount) in
      return commonTagsCount >= 2
    }).sorted(by: { artist1, artist2 -> Bool in
      if artist1.1 == artist2.1 {
        return artist1.0.playcount > artist2.0.playcount
      }
      return artist1.1 > artist2.1
    }).map({ SimilarArtistCellViewModel(artist: $0.0) })
  }
}
