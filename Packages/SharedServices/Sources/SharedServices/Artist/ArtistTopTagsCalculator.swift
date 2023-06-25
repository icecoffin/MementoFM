//
//  ArtistTopTagsCalculator.swift
//  MementoFM
//
//  Created by Daniel on 29/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import TransientModels

// MARK: - ArtistTopTagsCalculating

protocol ArtistTopTagsCalculating: AnyObject {
    func calculateTopTags(for artist: Artist, ignoredTags: [IgnoredTag]) -> Artist
}

// MARK: - ArtistTopTagsCalculator

final class ArtistTopTagsCalculator: ArtistTopTagsCalculating {
    // MARK: - Private properties

    private let numberOfTopTags: Int

    // MARK: - Init

    init(numberOfTopTags: Int = 5) {
        self.numberOfTopTags = numberOfTopTags
    }

    // MARK: - Public methods

    func calculateTopTags(for artist: Artist, ignoredTags: [IgnoredTag]) -> Artist {
        let topTags = artist.tags
            .filter { tag in
                !ignoredTags.contains(where: { ignoredTag in
                    tag.name == ignoredTag.name
                })
            }
            .sorted { $0.count > $1.count }
            .prefix(numberOfTopTags)

        return artist.updatingTopTags(to: Array(topTags))
    }
}
