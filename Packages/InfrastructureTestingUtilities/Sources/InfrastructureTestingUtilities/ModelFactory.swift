//
//  ModelFactory.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import TransientModels

public final class ModelFactory {
    public static func generateArtist(
        index: Int = 1,
        needsTagsUpdate: Bool = false,
        playcount: Int = 0,
        tags: [Tag] = [],
        topTags: [Tag] = []
    ) -> Artist {
        return Artist(
            name: "Artist\(index)",
            playcount: playcount,
            urlString: "http://example.com/artist\(index)",
            needsTagsUpdate: needsTagsUpdate,
            tags: tags,
            topTags: topTags,
            country: nil
        )
    }

    public static func generateArtists(inAmount amount: Int, needsTagsUpdate: Bool = false) -> [Artist] {
        return (1...amount).map { index in generateArtist(index: index, needsTagsUpdate: needsTagsUpdate) }
    }

    public static func generateTrack(index: Int = 1) -> Track {
        let artist = generateArtist(index: index)
        return Track(artist: artist)
    }

    public static func generateTracks(inAmount amount: Int) -> [Track] {
        return (1...amount).map { index in generateTrack(index: index) }
    }

    public static func generateTag(index: Int = 1, for artist: String) -> Tag {
        return Tag(name: "Tag\(artist)\(index)", count: index)
    }

    public static func generateTags(inAmount amount: Int, for artist: String) -> [Tag] {
        return (1...amount).map { index in generateTag(index: index, for: artist) }
    }

    public static func generateIgnoredTag(index: Int = 1) -> IgnoredTag {
        return IgnoredTag(uuid: "uuid\(index)", name: "IgnoredTag\(index)")
    }

    public static func generateIgnoredTags(inAmount amount: Int) -> [IgnoredTag] {
        return (1...amount).map { index in generateIgnoredTag(index: index) }
    }
}
