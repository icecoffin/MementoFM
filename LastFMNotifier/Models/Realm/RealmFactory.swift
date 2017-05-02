//
//  RealmFactory.swift
//  LastFMNotifier
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import RealmSwift

class RealmFactory {
  static func realm() -> Realm {
    do {
//      var config = Realm.Configuration()
//      config.deleteRealmIfMigrationNeeded = true
//      Realm.Configuration.defaultConfiguration = config
      let realm = try Realm()
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
