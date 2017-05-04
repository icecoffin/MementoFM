//
//  RealmGateway.swift
//  LastFMNotifier
//
//  Created by Daniel on 18/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit

class RealmGateway {
  let defaultRealm: Realm
  let getWriteRealm: () -> Realm

  init(defaultRealm: Realm, getWriteRealm: @escaping () -> Realm) {
    self.defaultRealm = defaultRealm
    self.getWriteRealm = getWriteRealm
  }

  func write(block: @escaping (Realm) -> Void) -> Promise<Void> {
    return dispatch_promise(DispatchQueue.global()) {
      let backgroundRealm = self.getWriteRealm()
      self.write(to: backgroundRealm) { realm in
        block(realm)
      }
    }.then(on: DispatchQueue.main) { [unowned self] in
      return self.refreshDefaultRealm()
    }
  }

  private func refreshDefaultRealm() -> Promise<Void> {
    return Promise { resolve, _ in
      defaultRealm.refresh()
      resolve()
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

  func save(objects: [Object]) -> Promise<Void> {
    return Promise { resolve, _ in
      DispatchQueue.global().async {
        let backgroundRealm = self.getWriteRealm()
        self.write(to: backgroundRealm) { realm in
          realm.add(objects, update: true)
        }
        DispatchQueue.main.async {
          self.defaultRealm.refresh()
          resolve()
        }
      }
    }
  }

  func deleteObjects<T: Object>(_ type: T.Type, in realm: Realm) {
    let objects = realm.objects(type)
    realm.delete(objects)
  }
}
