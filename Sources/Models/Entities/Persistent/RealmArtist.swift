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
    @Persisted(primaryKey: true) var id = ""
    @Persisted var name = ""
    @Persisted var playcount = 0
    @Persisted var urlString = ""
    @Persisted var needsTagsUpdate = true
    @Persisted var country: String?
    @Persisted var tags: List<RealmTag>
    @Persisted var topTags: List<RealmTag>

    static func from(transient: Artist) -> RealmArtist {
        let artist = transient
        let realmArtist = RealmArtist()
        realmArtist.id = artist.id
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
        return Artist(
            id: id,
            name: name,
            playcount: playcount,
            urlString: urlString,
            needsTagsUpdate: needsTagsUpdate,
            tags: tags.map({ $0.toTransient() }),
            topTags: topTags.map({ $0.toTransient() }),
            country: country
        )
    }
}

extension Artist: TransientEntity {
    typealias PersistentType = RealmArtist
}
