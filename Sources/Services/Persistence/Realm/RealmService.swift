//
//  RealmService.swift
//  MementoFM
//
//  Created by Daniel on 23/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit

final class RealmService: PersistentStore {
    private let mainQueueRealm: Realm
    private let getBackgroundQueueRealm: () -> Realm

    private let backgroundDispatcher: Dispatcher
    private let mainDispatcher: Dispatcher

    private var currentQueueRealm: Realm {
        if Thread.isMainThread {
            return self.mainQueueRealm
        } else {
            return getBackgroundQueueRealm()
        }
    }

    // MARK: - Init & factory methods
    init(getRealm: @escaping () -> Realm,
         backgroundDispatcher: Dispatcher = AsyncDispatcher.global,
         mainDispatcher: Dispatcher = AsyncDispatcher.main,
         migrator: RealmMigrating = RealmMigrator()) {
        migrator.performMigrations()

        self.mainQueueRealm = getRealm()
        self.getBackgroundQueueRealm = getRealm
        self.backgroundDispatcher = backgroundDispatcher
        self.mainDispatcher = mainDispatcher
    }

    // MARK: - Writing to Realm
    private func write(block: @escaping (Realm) -> Void) -> Promise<Void> {
        return backgroundDispatcher.dispatch {
            try self.write(to: self.currentQueueRealm) { realm in
                block(realm)
            }
        }.then(on: mainDispatcher.queue) { _ -> Promise<Void> in
            self.currentQueueRealm.refresh()
            return .value(())
        }.recover(on: mainDispatcher.queue) { error in
            return Promise(error: error)
        }
    }

    private func write(to realm: Realm, block: (Realm) -> Void) throws {
        try realm.write {
            block(realm)
        }
    }

    // MARK: - Realm mapped collection
    func mappedCollection<T: TransientEntity>(filteredUsing predicate: NSPredicate?,
                                              sortedBy sortDescriptors: [NSSortDescriptor]) -> AnyPersistentMappedCollection<T> {
        let realmMappedCollection = RealmMappedCollection<T>(realm: currentQueueRealm,
                                                             predicate: predicate,
                                                             sortDescriptors: sortDescriptors)
        return AnyPersistentMappedCollection(realmMappedCollection)
    }

    // MARK: - Saving objects to Realm
    func save<T: TransientEntity>(_ object: T, update: Bool = true) -> Promise<Void>
        where T.PersistentType.TransientType == T {
            return write { realm in
                if let realmObject = T.PersistentType.from(transient: object) as? Object {
                    realm.add(realmObject, update: .modified)
                }
            }
    }

    func save<T: TransientEntity>(_ objects: [T], update: Bool = true) -> Promise<Void>
        where T.PersistentType.TransientType == T {
            return write { realm in
                let realmObjects = objects.compactMap({ return T.PersistentType.from(transient: $0) as? Object })
                realm.add(realmObjects, update: .modified)
            }
    }

    // MARK: - Deleting objects from Realm
    func deleteObjects<T: TransientEntity>(ofType type: T.Type) -> Promise<Void>
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
    func objects<T: TransientEntity>(_ type: T.Type, filteredBy predicate: NSPredicate?) -> [T]
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

    func object<T: TransientEntity, K>(ofType type: T.Type, forPrimaryKey key: K) -> T?
        where T.PersistentType.TransientType == T {
            guard let type = T.PersistentType.self as? Object.Type else {
                fatalError("The provided Element.PersistentType is not a Realm Object subclass")
            }

            let realmObject = currentQueueRealm.object(ofType: type, forPrimaryKey: key)
            return (realmObject as? T.PersistentType)?.toTransient()
    }
}
