//
//  RealmService.swift
//  MementoFM
//
//  Created by Daniel on 23/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift
import Combine
import CombineSchedulers
import PersistenceInterface

public final class RealmService: PersistentStore {
    // MARK: - Private properties

    private let mainQueueRealm: Realm
    private let getBackgroundQueueRealm: () -> Realm

    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>
    private let mainScheduler: AnySchedulerOf<DispatchQueue>

    private var currentQueueRealm: Realm {
        if Thread.isMainThread {
            return self.mainQueueRealm
        } else {
            return getBackgroundQueueRealm()
        }
    }

    // MARK: - Init

    public init(getRealm: @escaping () -> Realm,
                backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler(),
                mainScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()) {
        self.mainQueueRealm = getRealm()
        self.getBackgroundQueueRealm = getRealm
        self.backgroundScheduler = backgroundScheduler
        self.mainScheduler = mainScheduler
    }

    // MARK: - Private methods

    private func write(block: @escaping (Realm) -> Void) -> AnyPublisher<Void, Error> {
        return Future<Void, Error>() { promise in
            self.backgroundScheduler.schedule {
                do {
                    try self.write(to: self.currentQueueRealm) { realm in
                        block(realm)
                        promise(.success(()))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: mainScheduler)
        .map {
            self.currentQueueRealm.refresh()
        }
        .eraseToAnyPublisher()
    }

    private func write(to realm: Realm, block: (Realm) -> Void) throws {
        try realm.write {
            block(realm)
        }
    }

    // MARK: - Public methods

    // MARK: - Realm mapped collection

    public func mappedCollection<T: TransientEntity>(
        filteredUsing predicate: NSPredicate?,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<T> {
        let realmMappedCollection = RealmMappedCollection<T>(realm: currentQueueRealm,
                                                             predicate: predicate,
                                                             sortDescriptors: sortDescriptors)
        return AnyPersistentMappedCollection(realmMappedCollection)
    }

    // MARK: - Saving objects to Realm

    public func save<T: TransientEntity>(_ object: T, update: Bool = true) -> AnyPublisher<Void, Error>
        where T.PersistentType.TransientType == T {
            return write { realm in
                if let realmObject = T.PersistentType.from(transient: object) as? Object {
                    realm.add(realmObject, update: .modified)
                }
            }
    }

    public func save<T: TransientEntity>(_ objects: [T], update: Bool = true) -> AnyPublisher<Void, Error>
        where T.PersistentType.TransientType == T {
            return write { realm in
                let realmObjects = objects.compactMap({ return T.PersistentType.from(transient: $0) as? Object })
                realm.add(realmObjects, update: .modified)
            }
    }

    // MARK: - Deleting objects from Realm

    public func deleteObjects<T: TransientEntity>(ofType type: T.Type) -> AnyPublisher<Void, Error>
        where T.PersistentType.TransientType == T {
            guard let type = type.PersistentType.self as? Object.Type else {
                fatalError("The provided Element.PersistentType is not a Realm Object subclass")
            }

            return write { realm in
                let realmObjects = realm.objects(type)
                realm.delete(realmObjects)
            }
    }

    // MARK: - Obtaining objects from Realm

    public func objects<T: TransientEntity>(_ type: T.Type, filteredBy predicate: NSPredicate?) -> [T]
        where T.PersistentType.TransientType == T {
            guard let type = T.PersistentType.self as? Object.Type else {
                fatalError("The provided Element.PersistentType is not a Realm Object subclass")
            }

            var results = currentQueueRealm.objects(type)
            if let predicate = predicate {
                results = results.filter(predicate)
            }
            return results.compactMap({ ($0 as? T.PersistentType)?.toTransient() })
    }

    public func object<T: TransientEntity, K>(ofType type: T.Type, forPrimaryKey key: K) -> T?
        where T.PersistentType.TransientType == T {
            guard let type = T.PersistentType.self as? Object.Type else {
                fatalError("The provided Element.PersistentType is not a Realm Object subclass")
            }

            let realmObject = currentQueueRealm.object(ofType: type, forPrimaryKey: key)
            return (realmObject as? T.PersistentType)?.toTransient()
    }
}
