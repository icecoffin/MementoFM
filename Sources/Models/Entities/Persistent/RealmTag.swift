//
//  RealmTag.swift
//  MementoFM
//
//  Created by Daniel on 09/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmTag: Object, PersistentEntity {
    @Persisted var name = ""
    @Persisted var count = 0

    static func from(transient: Tag) -> RealmTag {
        let tag = transient
        let realmTag = RealmTag()
        realmTag.name = tag.name
        realmTag.count = tag.count
        return realmTag
    }

    func toTransient() -> Tag {
        return Tag(name: name, count: count)
    }
}

extension Tag: TransientEntity {
    typealias PersistentType = RealmTag
}
