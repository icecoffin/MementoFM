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
    return "Tags: " + artist.topTags.map({ $0.name.lowercased() }).joined(separator: ", ")
  }

  var similarArtists: String {
    let topTagNames = artist.topTags.map({ $0.name })
    let predicate = NSPredicate(format: "ANY tags.name IN %@ AND name != %@", topTagNames, artist.name)
    let realmArtists = dependencies.realmGateway.defaultRealm.objects(RealmArtist.self).filter(predicate)

    let filteredArtists = realmArtists.filter({ realmArtist in
      let realmArtistTopTags = realmArtist.topTags.map({ $0.name })
      let commonTags = topTagNames.filter({ realmArtistTopTags.contains($0) })
      return commonTags.count >= 2
    }).sorted(by: { artist1, artist2 -> Bool in
      return artist1.name < artist2.name
    })
    return "Similar artists: " + filteredArtists.map({ $0.name }).joined(separator: ", ")
  }
}
