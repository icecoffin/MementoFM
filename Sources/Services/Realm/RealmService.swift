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
  fileprivate func write(block: @escaping (Realm) -> Void) -> Promise<Void> {
    return DispatchQueue.global().promise {
      self.write(to: self.currentQueueRealm) { realm in
        block(realm)
      }
    }.then(on: DispatchQueue.main) {
      return .void
    }
  }

  fileprivate func write(to realm: Realm, block: (Realm) -> Void) {
    do {
      try realm.write {
        block(realm)
      }
    } catch {
      fatalError("Can't write to Realm")
    }
  }

  // MARK: - Realm mapped collection
  func mappedCollection<T: TransientEntity>(filteredUsing predicate: NSPredicate? = nil,
                                            sortedBy sortDescriptors: [SortDescriptor]) -> RealmMappedCollection<T>
    where T.RealmType: Object {
    return RealmMappedCollection<T>(realm: currentQueueRealm,
                                       predicate: predicate,
                                       sortDescriptors: sortDescriptors)
  }

  // MARK: - Saving objects to Realm
  func save<T: TransientEntity>(_ object: T, update: Bool = true) -> Promise<Void>
    where T.RealmType.TransientType == T {
    return write { realm in
      if let realmObject = T.RealmType.from(transient: object) as? Object {
        realm.add(realmObject, update: update)
      }
    }
  }

  func save<T: TransientEntity>(_ objects: [T], update: Bool = true) -> Promise<Void>
    where T.RealmType.TransientType == T {
    return write { realm in
      let realmObjects = objects.flatMap({ return T.RealmType.from(transient: $0) as? Object })
      realm.add(realmObjects, update: update)
    }
  }

  // MARK: - Deleting objects from Realm

  func deleteObjects<T: TransientEntity>(ofType type: T.Type) -> Promise<Void>
    where T.RealmType: Object, T.RealmType.TransientType == T {
    return write { realm in
      let realmObjects = realm.objects(type.RealmType.self)
      realm.delete(realmObjects)
    }
  }

  // MARK: - Obtaining objects from Realm
  func hasObjects<T: TransientEntity>(ofType type: T.Type) -> Bool
    where T.RealmType: Object, T.RealmType.TransientType == T {
    return !currentQueueRealm.objects(T.RealmType.self).isEmpty
  }

  func objects<T: TransientEntity>(_ type: T.Type) -> [T.RealmType.TransientType]
    where T.RealmType: Object, T.RealmType.TransientType == T {
      return currentQueueRealm.objects(T.RealmType.self).flatMap({ $0.toTransient() })
  }

  func objects<T: TransientEntity>(_ type: T.Type, filteredBy predicate: NSPredicate) -> [T.RealmType.TransientType]
    where T.RealmType: Object, T.RealmType.TransientType == T {
    return currentQueueRealm.objects(T.RealmType.self).filter(predicate).flatMap({ $0.toTransient() })
  }

  func object<T: TransientEntity, K>(ofType type: T.Type, forPrimaryKey key: K) -> T.RealmType.TransientType?
    where T.RealmType: Object, T.RealmType.TransientType == T {
    if let realmObject = currentQueueRealm.object(ofType: T.RealmType.self, forPrimaryKey: key) {
      return realmObject.toTransient()
    } else {
      return nil
    }
  }
}
