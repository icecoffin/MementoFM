//
//  ArtistSimilarArtistsSectionViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

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
    DispatchQueue.global().async {
      let realm = self.dependencies.realmGateway.getWriteRealm()
      let topTagNames = self.artist.topTags.map({ $0.name })
      let predicate = NSPredicate(format: "ANY tags.name IN %@ AND name != %@", topTagNames, self.artist.name)
      let realmArtists = realm.objects(RealmArtist.self).filter(predicate)

      let filteredArtists = realmArtists.filter({ realmArtist in
        let realmArtistTopTags = realmArtist.topTags.map({ $0.name })
        let commonTags = topTagNames.filter({ realmArtistTopTags.contains($0) })
        return commonTags.count >= 2
      }).sorted(by: { artist1, artist2 -> Bool in
        return artist1.name < artist2.name
      }).map({ $0.toTransient() })

      self.cellViewModels = filteredArtists.map({ SimilarArtistCellViewModel(artist: $0) })
      DispatchQueue.main.async {
        self.isLoading = false
        self.didUpdateCellViewModels?()
      }
    }
  }
}
