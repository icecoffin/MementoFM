//
//  RealmArtist.swift
//  MementoFM
//
//  Created by Daniel on 20/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmArtist: Object, PersistentEntity {
    @objc dynamic var name = ""
    @objc dynamic var playcount = 0
    @objc dynamic var urlString = ""
    @objc dynamic var needsTagsUpdate = true
    @objc dynamic var country: String?
    var tags = List<RealmTag>()
    var topTags = List<RealmTag>()

    override static func primaryKey() -> String? {
        return "name"
    }

    class func from(transient: Artist) -> RealmArtist {
        let artist = transient
        let realmArtist = RealmArtist()
        realmArtist.name = artist.name
        realmArtist.playcount = artist.playcount
        realmArtist.urlString = artist.urlString
        realmArtist.needsTagsUpdate = artist.needsTagsUpdate
        realmArtist.country = artist.country
        for tag in artist.tags {
            let realmTag = RealmTag.from(transient: tag)
            realmArtist.tags.append(realmTag)
        }
        for topTag in artist.topTags {
            let realmTag = RealmTag.from(transient: topTag)
            realmArtist.topTags.append(realmTag)
        }
        return realmArtist
    }

    func toTransient() -> Artist {
        return Artist(name: name,
                      playcount: playcount,
                      urlString: urlString,
                      needsTagsUpdate: needsTagsUpdate,
                      tags: tags.map({ $0.toTransient() }),
                      topTags: topTags.map({ $0.toTransient() }),
                      country: country)
    }
}
