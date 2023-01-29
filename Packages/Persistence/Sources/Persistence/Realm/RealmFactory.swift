//
//  RealmFactory.swift
//  MementoFM
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import RealmSwift

public final class RealmFactory {
    public static func realm() -> Realm {
        do {
            let realm = try Realm()
            return realm
        } catch {
            fatalError("Can't create a Realm instance: \(error.localizedDescription)")
        }
    }

    public static func inMemoryRealm() -> Realm {
        do {
            let config = Realm.Configuration(inMemoryIdentifier: "InMemory")
            let realm = try Realm(configuration: config)
            return realm
        } catch {
            fatalError("Can't create an in-memory Realm instance: \(error.localizedDescription)")
        }
    }
}
