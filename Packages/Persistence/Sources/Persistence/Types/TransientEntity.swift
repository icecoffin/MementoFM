//
//  TransientEntity.swift
//  MementoFM
//
//  Created by Daniel on 28/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import TransientModels

public protocol TransientEntity {
    associatedtype PersistentType: PersistentEntity
}

extension Artist: TransientEntity {
    public typealias PersistentType = RealmArtist
}

extension IgnoredTag: TransientEntity {
    public typealias PersistentType = RealmIgnoredTag
}

extension Tag: TransientEntity {
    public typealias PersistentType = RealmTag
}
