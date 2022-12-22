//
//  Artist.swift
//  MementoFM
//
//  Created by Daniel on 06/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

public struct Artist: Equatable, Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case playcount
        case urlString = "url"
    }

    public let name: String
    public let playcount: Int
    public let urlString: String

    public let needsTagsUpdate: Bool
    public let tags: [Tag]
    public let topTags: [Tag]

    public let country: String?

    public init(
        name: String,
        playcount: Int,
        urlString: String,
        needsTagsUpdate: Bool,
        tags: [Tag],
        topTags: [Tag],
        country: String? = nil
    ) {
        self.name = name
        self.playcount = playcount
        self.urlString = urlString
        self.needsTagsUpdate = needsTagsUpdate
        self.tags = tags
        self.topTags = topTags
        self.country = country
    }

    public func intersectingTopTagNames(with artist: Artist) -> [String] {
        let topTagNames = topTags.map({ $0.name })
        let otherTopTagNames = artist.topTags.map({ $0.name })
        return topTagNames.filter({ otherTopTagNames.contains($0) })
    }

    public func updatingPlaycount(to playcount: Int) -> Artist {
        return Artist(name: name,
                      playcount: playcount,
                      urlString: urlString,
                      needsTagsUpdate: needsTagsUpdate,
                      tags: tags,
                      topTags: topTags,
                      country: country)
    }

    public func updatingTags(to tags: [Tag], needsTagsUpdate: Bool) -> Artist {
        return Artist(name: name,
                      playcount: playcount,
                      urlString: urlString,
                      needsTagsUpdate: needsTagsUpdate,
                      tags: tags,
                      topTags: topTags,
                      country: country)
    }

    public func updatingTopTags(to topTags: [Tag]) -> Artist {
        return Artist(name: name,
                      playcount: playcount,
                      urlString: urlString,
                      needsTagsUpdate: needsTagsUpdate,
                      tags: tags,
                      topTags: topTags,
                      country: country)
    }

    public func updatingCountry(to country: String) -> Artist {
        return Artist(name: name,
                      playcount: playcount,
                      urlString: urlString,
                      needsTagsUpdate: needsTagsUpdate,
                      tags: tags,
                      topTags: topTags,
                      country: country)
    }
}

extension Artist {
    public init(from decoder: Decoder) throws {
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
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(playcount)
        hasher.combine(urlString)
    }
}
