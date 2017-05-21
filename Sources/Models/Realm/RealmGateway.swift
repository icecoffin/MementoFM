//
//  RealmGateway.swift
//  MementoFM
//
//  Created by Daniel on 18/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit

class RealmGateway {
  let mainQueueRealm: Realm
  let getCurrentQueueRealm: () -> Realm

  init(mainQueueRealm: Realm, getCurrentQueueRealm: @escaping () -> Realm) {
    self.mainQueueRealm = mainQueueRealm
    self.getCurrentQueueRealm = getCurrentQueueRealm
  }

  func write(block: @escaping (Realm) -> Void) -> Promise<Void> {
    return dispatch_promise(DispatchQueue.global()) {
      let currentQueueRealm = self.getCurrentQueueRealm()
      self.write(to: currentQueueRealm) { realm in
        block(realm)
      }
    }.then(on: DispatchQueue.main) { [unowned self] in
      return self.refreshMainQueueRealm()
    }
  }

  private func refreshMainQueueRealm() -> Promise<Void> {
    return Promise { resolve, _ in
      mainQueueRealm.refresh()
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
}
