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
  let mainQueueRealm: Realm
  let getBackgroundQueueRealm: () -> Realm

  init(mainQueueRealm: Realm, getBackgroundQueueRealm: @escaping () -> Realm) {
    self.mainQueueRealm = mainQueueRealm
    self.getBackgroundQueueRealm = getBackgroundQueueRealm
  }

  func write(block: @escaping (Realm) -> Void) -> Promise<Void> {
    return dispatch_promise(DispatchQueue.global()) {
      let backgroundRealm = self.getBackgroundQueueRealm()
      self.write(to: backgroundRealm) { realm in
        block(realm)
      }
    }.then(on: DispatchQueue.main) { [unowned self] in
      return self.refreshDefaultRealm()
    }
  }

  private func refreshDefaultRealm() -> Promise<Void> {
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
