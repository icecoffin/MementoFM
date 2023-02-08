//
//  PersistentStore.swift
//  MementoFM
//
//  Created by Dani on 28/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
import Combine

public protocol PersistentStore {
    func mappedCollection<T: TransientEntity>(filteredUsing predicate: NSPredicate?,
                                              sortedBy sortDescriptors: [NSSortDescriptor]) -> AnyPersistentMappedCollection<T>

    func save<T: TransientEntity>(_ objects: [T], update: Bool) -> AnyPublisher<Void, Error>
        where T.PersistentType.TransientType == T

    func deleteObjects<T: TransientEntity>(ofType type: T.Type) -> AnyPublisher<Void, Error>
        where T.PersistentType.TransientType == T

    func objects<T: TransientEntity>(_ type: T.Type, filteredBy predicate: NSPredicate?) -> [T]
        where T.PersistentType.TransientType == T

    func object<T: TransientEntity, K>(ofType type: T.Type, forPrimaryKey key: K) -> T?
        where T.PersistentType.TransientType == T
}

public extension PersistentStore {
    func objects<T: TransientEntity>(_ type: T.Type) -> [T]
        where T.PersistentType.TransientType == T {
            return objects(type, filteredBy: nil)
    }

    func save<T: TransientEntity>(_ objects: [T]) -> AnyPublisher<Void, Error>
        where T.PersistentType.TransientType == T {
            return save(objects, update: true)
    }

    func save<T: TransientEntity>(_ object: T, update: Bool = true) -> AnyPublisher<Void, Error>
        where T.PersistentType.TransientType == T {
            return save([object], update: update)
    }
}
