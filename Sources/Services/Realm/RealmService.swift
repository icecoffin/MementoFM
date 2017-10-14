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
  let getRealm: () -> Realm

  // MARK: - Init & factory methods
  init(getRealm: @escaping () -> Realm) {
    self.getRealm = getRealm
  }

  class func persistent() -> RealmService {
    return RealmService(getRealm: {
      return RealmFactory.realm()
    })
  }

  class func inMemory() -> RealmService {
    return RealmService(getRealm: {
      return RealmFactory.inMemoryRealm()
    })
  }

  // MARK: - Writing to Realm
  func write(block: @escaping (Realm) -> Void) -> Promise<Void> {
    return DispatchQueue.global().promise {
      let currentQueueRealm = self.getRealm()
      self.write(to: currentQueueRealm) { realm in
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

  // MARK: - Saving objects to Realm
  func save<T: TransientEntity>(_ object: T, update: Bool = true) -> Promise<Void> where T.RealmType.TransientType == T {
    return write { realm in
      if let realmObject = T.RealmType.from(transient: object) as? Object {
        realm.add(realmObject, update: update)
      }
    }
  }

  func save<T: TransientEntity>(_ objects: [T], update: Bool = true) -> Promise<Void> where T.RealmType.TransientType == T {
    return write { realm in
      let realmObjects = objects.flatMap({ return T.RealmType.from(transient: $0) as? Object })
      realm.add(realmObjects, update: update)
    }
  }

  // MARK: - Deleting objects from Realm

  func deleteObjects<T: TransientEntity>(ofType type: T.Type) -> Promise<Void> where T.RealmType: Object, T.RealmType.TransientType == T {
    return write { realm in
      let realmObjects = realm.objects(T.RealmType.self)
      realm.delete(realmObjects)
    }
  }

  // MARK: - Obtaining objects from Realm
  func hasObjects<T: TransientEntity>(ofType type: T.Type) -> Bool where T.RealmType: Object, T.RealmType.TransientType == T {
    return !getRealm().objects(T.RealmType.self).isEmpty
  }

  func objects<T: TransientEntity>(_ type: T.Type) -> [T.RealmType.TransientType]
    where T.RealmType: Object, T.RealmType.TransientType == T {
      return getRealm().objects(T.RealmType.self).flatMap({ $0.toTransient() })
  }

  func objects<T: TransientEntity>(_ type: T.Type, filteredBy predicate: NSPredicate) -> [T.RealmType.TransientType]
    where T.RealmType: Object, T.RealmType.TransientType == T {
    return getRealm().objects(T.RealmType.self).filter(predicate).flatMap({ $0.toTransient() })
  }

  func object<T: TransientEntity, K>(ofType type: T.Type, forPrimaryKey key: K) -> T.RealmType.TransientType?
    where T.RealmType: Object, T.RealmType.TransientType == T {
    if let realmObject = getRealm().object(ofType: T.RealmType.self, forPrimaryKey: key) {
      return realmObject.toTransient()
    } else {
      return nil
    }
  }
}
