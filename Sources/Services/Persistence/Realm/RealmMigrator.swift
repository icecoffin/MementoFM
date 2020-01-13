//
//  RealmMigrator.swift
//  MementoFM
//
//  Created by Dani on 12.06.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmMigrating {
  func performMigrations()
}

final class RealmMigrator: RealmMigrating {
  func performMigrations() {
    let config = Realm.Configuration(schemaVersion: 2, migrationBlock: { _, oldSchemaVersion in
      if oldSchemaVersion < 1 {
        // Property 'RealmArtist.imageURLString' has been removed.
      }

      if oldSchemaVersion < 2 {
        // Property 'RealmArtist.country' has been added.
      }
    })

    Realm.Configuration.defaultConfiguration = config
  }
}
