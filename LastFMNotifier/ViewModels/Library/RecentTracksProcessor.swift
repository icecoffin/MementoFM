//
//  RecentTracksProcessor.swift
//  LastFMNotifier
//
//  Created by Daniel on 08/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

class RecentTracksProcessor {
  func process(tracks: [Track],
               usingRealmGateway realmGateway: RealmGateway) -> Promise<[Artist]> {
    log.debug("processing \(tracks.count) tracks")
    var artistNamesWithPlayCounts = [Artist: Int]()

    for track in tracks {
      let artist = track.artist
      if let count = artistNamesWithPlayCounts[artist] {
        artistNamesWithPlayCounts[artist] = count + 1
      } else {
        artistNamesWithPlayCounts[artist] = 1
      }
    }

    log.debug(artistNamesWithPlayCounts.map {
      return ($0.key.name, $0.value)
    })

    var newArtists = [Artist]()

    return realmGateway.write(block: { realm in
      for (artist, playCount) in artistNamesWithPlayCounts {
        let realmArtist: RealmArtist
        if let existingArtist = realm.object(ofType: RealmArtist.self, forPrimaryKey: artist.name) {
          realmArtist = existingArtist
        } else {
          realmArtist = RealmArtist.from(artist: artist)
          realm.add(realmArtist)
          newArtists.append(artist)
        }
        realmArtist.playcount += playCount
      }
    }).then(execute: { _ -> Promise<[Artist]> in
      return Promise(value: newArtists)
    })
  }
}
