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
  private let cellViewModels: [SimilarArtistCellViewModel]

  required init(artist: Artist, dependencies: Dependencies) {
    self.artist = artist
    self.dependencies = dependencies

    let topTagNames = artist.topTags.map({ $0.name })
    let predicate = NSPredicate(format: "ANY tags.name IN %@ AND name != %@", topTagNames, artist.name)
    let realmArtists = dependencies.realmGateway.defaultRealm.objects(RealmArtist.self).filter(predicate)

    let filteredArtists = realmArtists.filter({ realmArtist in
      let realmArtistTopTags = realmArtist.topTags.map({ $0.name })
      let commonTags = topTagNames.filter({ realmArtistTopTags.contains($0) })
      return commonTags.count >= 2
    }).sorted(by: { artist1, artist2 -> Bool in
      return artist1.name < artist2.name
    }).map({ $0.toTransient() })

    cellViewModels = filteredArtists.map({ SimilarArtistCellViewModel(artist: $0) })
  }

  var numberOfSimilarArtists: Int {
    return cellViewModels.count
  }

  var sectionHeaderText: String? {
    return "Similar artists".unlocalized
  }

  func cellViewModel(at indexPath: IndexPath) -> SimilarArtistCellViewModel {
    return cellViewModels[indexPath.item]
  }
}
