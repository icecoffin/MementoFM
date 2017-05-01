//
//  ArtistViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class ArtistViewModel {
  typealias Dependencies = HasRealmGateway

  private let artist: Artist
  private let dependencies: Dependencies

  init(artist: Artist, dependencies: Dependencies) {
    self.artist = artist
    self.dependencies = dependencies
  }

  var title: String {
    return artist.name
  }

  var imageURL: URL? {
    if let imageURLString = artist.imageURLString {
      return URL(string: imageURLString)
    } else {
      return nil
    }
  }

  var tags: String {
    let topTags = artist.tags.prefix(5)
    return "Tags: " + topTags.map({ $0.name.lowercased() }).joined(separator: ", ")
  }

  var similarArtists: String {
    let topTags = artist.tags.prefix(5)
    let topTagNames = topTags.map({ $0.name })
    log.debug("Top tags: \(topTagNames)")
    let predicate = NSPredicate(format: "ANY tags.name IN %@ AND name != %@", topTagNames, artist.name)
    let realmArtists = dependencies.realmGateway.defaultRealm.objects(RealmArtist.self).filter(predicate)

    let filteredArtists = realmArtists.filter({ realmArtist in
      let realmArtistTags = realmArtist.tags.map({ $0.name }).prefix(5)
      let commonTags = topTagNames.filter({ realmArtistTags.contains($0) })
      return commonTags.count >= 3
    }).sorted(by: { artist1, artist2 -> Bool in
      return artist1.name < artist2.name
    })
    return "Similar artists: " + filteredArtists.map({ $0.name }).joined(separator: ", ")
  }
}
