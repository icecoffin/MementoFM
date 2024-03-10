//
//  RealmIgnoredTag.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmIgnoredTag: Object, PersistentEntity {
    @objc dynamic var uuid = UUID().uuidString
    @objc dynamic var name = ""

    override static func primaryKey() -> String? {
        return "uuid"
    }

    static func from(transient: IgnoredTag) -> RealmIgnoredTag {
        let ignoredTag = transient
        let realmIgnoredTag = RealmIgnoredTag()
        realmIgnoredTag.uuid = ignoredTag.uuid
        realmIgnoredTag.name = ignoredTag.name
        return realmIgnoredTag
    }

    func toTransient() -> IgnoredTag {
        return IgnoredTag(uuid: uuid, name: name)
    }
}

extension IgnoredTag: TransientEntity {
    typealias PersistentType = RealmIgnoredTag
}
