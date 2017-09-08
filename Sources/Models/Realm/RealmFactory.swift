//
//  RealmFactory.swift
//  MementoFM
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import RealmSwift

class RealmFactory {
  static func realm() -> Realm {
    do {
      let realm = try Realm()
      realm.refresh()
      return realm
    } catch {
      fatalError("Can't create a Realm instance")
    }
  }

  static func inMemoryRealm() -> Realm {
    do {
      let config = Realm.Configuration(inMemoryIdentifier: "InMemory")
      let realm = try Realm(configuration: config)
      return realm
    } catch {
      fatalError("Can't create an in-memory Realm instance")
    }
  }
}
