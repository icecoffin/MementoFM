//
//  Artist.swift
//  MementoFM
//
//  Created by Daniel on 06/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

struct Artist: TransientEntity, Equatable, Codable {
    typealias PersistentType = RealmArtist

    enum CodingKeys: String, CodingKey {
        case name
        case playcount
        case urlString = "url"
    }

    let name: String
    let playcount: Int
    let urlString: String

    let needsTagsUpdate: Bool
    let tags: [Tag]
    let topTags: [Tag]

    let country: String?

    func intersectingTopTagNames(with artist: Artist) -> [String] {
        let topTagNames = topTags.map({ $0.name })
        let otherTopTagNames = artist.topTags.map({ $0.name })
        return topTagNames.filter({ otherTopTagNames.contains($0) })
    }

    func updatingPlaycount(to playcount: Int) -> Artist {
        return Artist(
            name: name,
            playcount: playcount,
            urlString: urlString,
            needsTagsUpdate: needsTagsUpdate,
            tags: tags,
            topTags: topTags,
            country: country
        )
    }

    func updatingTags(to tags: [Tag], needsTagsUpdate: Bool) -> Artist {
        return Artist(
            name: name,
            playcount: playcount,
            urlString: urlString,
            needsTagsUpdate: needsTagsUpdate,
            tags: tags,
            topTags: topTags,
            country: country
        )
    }

    func updatingTopTags(to topTags: [Tag]) -> Artist {
        return Artist(
            name: name,
            playcount: playcount,
            urlString: urlString,
            needsTagsUpdate: needsTagsUpdate,
            tags: tags,
            topTags: topTags,
            country: country
        )
    }

    func updatingCountry(to country: String) -> Artist {
        return Artist(
            name: name,
            playcount: playcount,
            urlString: urlString,
            needsTagsUpdate: needsTagsUpdate,
            tags: tags,
            topTags: topTags,
            country: country
        )
    }
}

extension Artist {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        if let playcountString = try container.decodeIfPresent(String.self, forKey: .playcount) {
            self.playcount = int(from: playcountString)
        } else {
            self.playcount = 0
        }

        urlString = try container.decodeIfPresent(String.self, forKey: .urlString) ?? ""

        needsTagsUpdate = true
        tags = []
        topTags = []
        country = nil
    }
}

extension Artist: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(playcount)
        hasher.combine(urlString)
    }
}
