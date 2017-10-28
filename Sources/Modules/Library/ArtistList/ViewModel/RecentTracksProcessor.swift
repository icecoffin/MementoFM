//
//  RecentTracksProcessor.swift
//  MementoFM
//
//  Created by Daniel on 08/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol RecentTracksProcessing {
  func process(tracks: [Track], using realmService: RealmService) -> Promise<Void>
}

class RecentTracksProcessor: RecentTracksProcessing {
  func process(tracks: [Track], using realmService: RealmService) -> Promise<Void> {
    var artistNamesWithPlayCounts = [Artist: Int]()

    for track in tracks {
      let artist = track.artist
      if let count = artistNamesWithPlayCounts[artist] {
        artistNamesWithPlayCounts[artist] = count + 1
      } else {
        artistNamesWithPlayCounts[artist] = 1
      }
    }

    let artists: [Artist] = artistNamesWithPlayCounts.map { artist, playcount in
      let updatedArtist = realmService.object(ofType: Artist.self, forPrimaryKey: artist.name) ?? artist
      return updatedArtist.updatingPlaycount(updatedArtist.playcount + playcount)
    }

    return realmService.save(artists)
  }
}
