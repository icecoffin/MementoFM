//
//  MockPersistentStore.swift
//  MementoFM
//
//  Created by Dani on 28/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
import Combine
import PersistenceInterface

public final class MockPersistentStore: PersistentStore {
    public init() { }

    public var customMappedCollection: Any?
    public var mappedCollectionParameters: (predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor])?
    public func mappedCollection<T: TransientEntity>(
        filteredUsing predicate: NSPredicate?,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<T> {
        mappedCollectionParameters = (predicate, sortDescriptors)
        guard let customMappedCollection = customMappedCollection as? AnyPersistentMappedCollection<T> else {
            fatalError("customMappedCollection is either not set or has a wrong type (should be of \(T.self)")
        }
        return customMappedCollection
    }

    public var saveParameters: (objects: [Any], update: Bool)?
    public func save<T: TransientEntity>(_ objects: [T], update: Bool) -> AnyPublisher<Void, Error>
    where T.PersistentType.TransientType == T {
        saveParameters = (objects: objects, update: update)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public var didCallDelete = false
    public var deletedObjectsTypeNames: [String] = []
    public func deleteObjects<T: TransientEntity>(ofType type: T.Type) -> AnyPublisher<Void, Error>
    where T.PersistentType.TransientType == T {
        didCallDelete = true
        deletedObjectsTypeNames.append(String(describing: type))
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public var customObjects: [Any] = []
    public var objectsPredicate: NSPredicate?
    public func objects<T: TransientEntity>(_ type: T.Type, filteredBy predicate: NSPredicate?) -> [T]
        where T.PersistentType.TransientType == T {
            guard let customObjects = customObjects as? [T.PersistentType.TransientType] else {
                fatalError("customObjects has an incorrect type (should be of \(T.self))")
            }
            objectsPredicate = predicate
            return customObjects
    }

    public var customObjectForKey: Any?
    public var objectPrimaryKeys: [String] = []
    public func object<T: TransientEntity, K>(ofType type: T.Type, forPrimaryKey key: K) -> T?
        where T.PersistentType.TransientType == T {
            if let key = key as? String {
                objectPrimaryKeys.append(key)
            }

            guard let customObjectForKey = customObjectForKey else {
                return nil
            }

            guard let object = customObjectForKey as? T else {
                fatalError("customObject should be of type \(T.self)")
            }

            return object
    }
}
