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

class RealmService {
  private let mainQueueRealm: Realm
  private let getBackgroundQueueRealm: () -> Realm

  private var currentQueueRealm: Realm {
    if Thread.isMainThread {
      return self.mainQueueRealm
    } else {
      return getBackgroundQueueRealm()
    }
  }

  // MARK: - Init & factory methods
  init(getRealm: @escaping () -> Realm) {
    self.mainQueueRealm = getRealm()
    self.getBackgroundQueueRealm = getRealm
  }

  // MARK: - Writing to Realm
  private func write(block: @escaping (Realm) -> Void) -> Promise<Void> {
    return DispatchQueue.global().async(.promise) {
      try self.write(to: self.currentQueueRealm) { realm in
        block(realm)
      }
    }.then(on: DispatchQueue.main) { _ -> Promise<Void> in
      self.currentQueueRealm.refresh()
      return .value(())
    }.recover(on: DispatchQueue.main) { error in
      return Promise(error: error)
    }
  }

  private func write(to realm: Realm, block: (Realm) -> Void) throws {
    try realm.write {
      block(realm)
    }
  }

  // MARK: - Realm mapped collection
  func mappedCollection<T: TransientEntity>(filteredUsing predicate: NSPredicate? = nil,
                                            sortedBy sortDescriptors: [NSSortDescriptor]) -> RealmMappedCollection<T>
    where T.PersistentType: Object {
    return RealmMappedCollection<T>(realm: currentQueueRealm,
                                       predicate: predicate,
                                       sortDescriptors: sortDescriptors)
  }

  // MARK: - Saving objects to Realm
  func save<T: TransientEntity>(_ object: T, update: Bool = true) -> Promise<Void>
    where T.PersistentType.TransientType == T {
    return write { realm in
      if let realmObject = T.PersistentType.from(transient: object) as? Object {
        realm.add(realmObject, update: update)
      }
    }
  }

  func save<T: TransientEntity>(_ objects: [T], update: Bool = true) -> Promise<Void>
    where T.PersistentType.TransientType == T {
    return write { realm in
      let realmObjects = objects.compactMap({ return T.PersistentType.from(transient: $0) as? Object })
      realm.add(realmObjects, update: update)
    }
  }

  // MARK: - Deleting objects from Realm

  func deleteObjects<T: TransientEntity>(ofType type: T.Type) -> Promise<Void>
    where T.PersistentType: Object, T.PersistentType.TransientType == T {
    return write { realm in
      let realmObjects = realm.objects(type.PersistentType.self)
      realm.delete(realmObjects)
    }
  }

  // MARK: - Obtaining objects from Realm
  func hasObjects<T: TransientEntity>(ofType type: T.Type) -> Bool
    where T.PersistentType: Object, T.PersistentType.TransientType == T {
    return !currentQueueRealm.objects(T.PersistentType.self).isEmpty
  }

  func objects<T: TransientEntity>(_ type: T.Type) -> [T.PersistentType.TransientType]
    where T.PersistentType: Object, T.PersistentType.TransientType == T {
      return currentQueueRealm.objects(T.PersistentType.self).compactMap({ $0.toTransient() })
  }

  func objects<T: TransientEntity>(_ type: T.Type, filteredBy predicate: NSPredicate) -> [T.PersistentType.TransientType]
    where T.PersistentType: Object, T.PersistentType.TransientType == T {
    return currentQueueRealm.objects(T.PersistentType.self).filter(predicate).compactMap({ $0.toTransient() })
  }

  func object<T: TransientEntity, K>(ofType type: T.Type, forPrimaryKey key: K) -> T.PersistentType.TransientType?
    where T.PersistentType: Object, T.PersistentType.TransientType == T {
    if let realmObject = currentQueueRealm.object(ofType: T.PersistentType.self, forPrimaryKey: key) {
      return realmObject.toTransient()
    } else {
      return nil
    }
  }
}
