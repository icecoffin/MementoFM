//
//  TransientEntity.swift
//  MementoFM
//
//  Created by Daniel on 28/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import TransientModels

protocol TransientEntity {
    associatedtype PersistentType: PersistentEntity
}

extension Artist: TransientEntity {
    typealias PersistentType = RealmArtist
}

extension IgnoredTag: TransientEntity {
    typealias PersistentType = RealmIgnoredTag
}

extension Tag: TransientEntity {
    typealias PersistentType = RealmTag
}
