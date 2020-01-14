//
//  ModelFactory.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM

class ModelFactory {
    class func generateArtist(index: Int = 1, needsTagsUpdate: Bool = false) -> Artist {
        return Artist(name: "Artist\(index)",
            playcount: 0,
            urlString: "http://example.com/artist\(index)",
            needsTagsUpdate: needsTagsUpdate,
            tags: [],
            topTags: [],
            country: nil)
    }

    class func generateArtists(inAmount amount: Int, needsTagsUpdate: Bool = false) -> [Artist] {
        return (1...amount).map { index in generateArtist(index: index, needsTagsUpdate: needsTagsUpdate) }
    }

    class func generateTrack(index: Int = 1) -> Track {
        let artist = generateArtist(index: index)
        return Track(artist: artist)
    }

    class func generateTracks(inAmount amount: Int) -> [Track] {
        return (1...amount).map { index in generateTrack(index: index) }
    }

    class func generateTag(index: Int = 1, for artist: String) -> Tag {
        return Tag(name: "Tag\(artist)\(index)", count: index)
    }

    class func generateTags(inAmount amount: Int, for artist: String) -> [Tag] {
        return (1...amount).map { index in generateTag(index: index, for: artist) }
    }

    class func generateIgnoredTag(index: Int = 1) -> IgnoredTag {
        return IgnoredTag(uuid: "uuid\(index)", name: "IgnoredTag\(index)")
    }

    class func generateIgnoredTags(inAmount amount: Int) -> [IgnoredTag] {
        return (1...amount).map { index in generateIgnoredTag(index: index) }
    }

    class func generateSimilarArtists(inAmount amount: Int) -> [SimilarArtist] {
        return (1...amount).map { index in SimilarArtist(name: "Artist\(index)") }
    }
}
