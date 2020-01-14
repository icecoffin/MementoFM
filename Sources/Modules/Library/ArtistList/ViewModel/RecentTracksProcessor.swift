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
    func process(tracks: [Track], using persistentStore: PersistentStore) -> Promise<Void>
}

final class RecentTracksProcessor: RecentTracksProcessing {
    func process(tracks: [Track], using persistentStore: PersistentStore) -> Promise<Void> {
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
            let updatedArtist = persistentStore.object(ofType: Artist.self, forPrimaryKey: artist.name) ?? artist
            return updatedArtist.updatingPlaycount(to: updatedArtist.playcount + playcount)
        }

        return persistentStore.save(artists)
    }
}
