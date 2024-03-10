//
//  RecentTracksProcessor.swift
//  MementoFM
//
//  Created by Daniel on 08/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - RecentTracksProcessing

protocol RecentTracksProcessing {
    func process(tracks: [Track]) -> AnyPublisher<Void, Error>
}

// MARK: - RecentTracksProcessor

final class RecentTracksProcessor: RecentTracksProcessing {
    private let persistentStore: PersistentStore

    init(persistentStore: PersistentStore) {
        self.persistentStore = persistentStore
    }

    func process(tracks: [Track]) -> AnyPublisher<Void, Error> {
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
