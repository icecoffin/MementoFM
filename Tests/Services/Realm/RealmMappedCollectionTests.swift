//
//  RealmMappedCollectionTests.swift
//  MementoFM
//
//  Created by Daniel on 05/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest

@testable import MementoFM
import RealmSwift

final class RealmMappedCollectionTests: XCTestCase {
    private var realm: Realm!
    private var collection: RealmMappedCollection<Tag>!

    override func setUp() {
        super.setUp()

        realm = RealmFactory.inMemoryRealm()
        collection = RealmMappedCollection(realm: realm, sortDescriptors: [])
    }

    override func tearDown() {
        collection = nil
        realm = nil

        super.tearDown()
    }

    func test_count_returnsCorrectValue() {
        try? realm.write {
            let tag = RealmTag()
            realm.add(tag)
        }
        XCTAssertEqual(collection.count, 1)
    }

    func test_isEmpty_returnsTrue_whenCollectionIsEmpty() {
        XCTAssertTrue(collection.isEmpty)
    }

    func test_isEmpty_returnsFalse_whenCollectionIsNotEmpty() {
        try? realm.write {
            let tag = RealmTag()
            realm.add(tag)
        }
        XCTAssertFalse(collection.isEmpty)
    }

    func test_subscript_returnsCorrectItemForIndex() {
        try? realm.write {
            let tag1 = RealmTag(name: "rock", count: 1)
            let tag2 = RealmTag(name: "metal", count: 2)
            realm.add([tag1, tag2])
        }

        let secondTag = collection[1]
        XCTAssertEqual(secondTag.name, "metal")
        XCTAssertEqual(secondTag.count, 2)
    }

    func test_settingPredicate_filtersCollection() {
        try? realm.write {
            let tag1 = RealmTag(name: "rock", count: 1)
            let tag2 = RealmTag(name: "metal", count: 2)
            realm.add([tag1, tag2])
        }
        let predicate = NSPredicate(format: "count > 1")
        collection.predicate = predicate
        XCTAssertEqual(collection.count, 1)

        collection.predicate = nil
        XCTAssertEqual(collection.count, 2)
    }

    func test_settingSortDescriptors_sortsCollection() {
        try? realm.write {
            let tag1 = RealmTag(name: "rock", count: 1)
            let tag2 = RealmTag(name: "indie", count: 2)
            let tag3 = RealmTag(name: "indie", count: 3)
            realm.add([tag1, tag2, tag3])
        }
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
                               NSSortDescriptor(key: "count", ascending: false)]
        collection.sortDescriptors = sortDescriptors

        XCTAssertEqual(collection[0].count, 3)
        XCTAssertEqual(collection[0].name, collection[1].name)
        XCTAssertEqual(collection[2].name, "rock")
    }
}
