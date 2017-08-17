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

  class var persistent: RealmService {
    return RealmService(getRealm: {
      return RealmFactory.realm()
    })
  }

  class var inMemory: RealmService {
    return RealmService(getRealm: {
      return RealmFactory.inMemoryRealm()
    })
  }

  // MARK: - Writing to Realm
  func write(block: @escaping (Realm) -> Void) -> Promise<Void> {
    return dispatch_promise(DispatchQueue.global()) {
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

  // MARK: - Obtaining objects from Realm
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
