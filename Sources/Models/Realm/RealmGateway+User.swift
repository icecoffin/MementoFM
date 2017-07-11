//
//  RealmGateway+User.swift
//  MementoFM
//
//  Created by Daniel on 15/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift

protocol UserDatabaseService {
  func clearLocalData() -> Promise<Void>
}

extension RealmGateway: UserDatabaseService {
  func clearLocalData() -> Promise<Void> {
    return write(block: { realm in
      self.deleteObjects(RealmArtist.self, in: realm)
      self.deleteObjects(RealmTag.self, in: realm)
    })
  }

  private func deleteObjects<T: Object>(_ type: T.Type, in realm: Realm) {
    let objects = realm.objects(type)
    realm.delete(objects)
  }
}
