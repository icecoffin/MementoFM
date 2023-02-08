//
//  RealmTag.swift
//  MementoFM
//
//  Created by Daniel on 09/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift
import PersistenceInterface
import TransientModels

public final class RealmTag: Object, PersistentEntity {
    @objc dynamic var name = ""
    @objc dynamic var count = 0

    public static func from(transient: Tag) -> RealmTag {
        let tag = transient
        let realmTag = RealmTag()
        realmTag.name = tag.name
        realmTag.count = tag.count
        return realmTag
    }

    public func toTransient() -> Tag {
        return Tag(name: name, count: count)
    }
}

extension Tag: TransientEntity {
    public typealias PersistentType = RealmTag
}
