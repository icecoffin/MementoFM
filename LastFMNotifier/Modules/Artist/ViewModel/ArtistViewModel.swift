//
//  ArtistViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class ArtistViewModel {
  private let artist: Artist
  private let realmGateway: RealmGateway

  init(artist: Artist, realmGateway: RealmGateway) {
    self.artist = artist
    self.realmGateway = realmGateway
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
    print("Top tags: \(topTagNames)")
    let predicate = NSPredicate(format: "ANY tags.name IN %@ AND name != %@", topTagNames, artist.name)
    let realmArtists = realmGateway.defaultRealm.objects(RealmArtist.self).filter(predicate)

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
