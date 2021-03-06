//
//  RealmMappedCollectionTests.swift
//  MementoFM
//
//  Created by Daniel on 05/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
import Nimble
@testable import MementoFM
import RealmSwift

class RealmMappedCollectionTests: XCTestCase {
    var realm: Realm!
    var collection: RealmMappedCollection<Tag>!

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
        expect(self.collection.count).toEventually(equal(1))
    }

    func test_isEmpty_returnsTrue_whenCollectionIsEmpty() {
        expect(self.collection.isEmpty).to(beTrue())
    }

    func test_isEmpty_returnsFalse_whenCollectionIsNotEmpty() {
        try? realm.write {
            let tag = RealmTag()
            realm.add(tag)
        }
        expect(self.collection.isEmpty).toEventually(beFalse())
    }

    func test_subscript_returnsCorrectItemForIndex() {
        try? realm.write {
            let tag1 = RealmTag(name: "rock", count: 1)
            let tag2 = RealmTag(name: "metal", count: 2)
            realm.add([tag1, tag2])
        }

        let secondTag = collection[1]
        expect(secondTag.name).toEventually(equal("metal"))
        expect(secondTag.count).toEventually(equal(2))
    }

    func test_settingPredicate_filtersCollection() {
        try? realm.write {
            let tag1 = RealmTag(name: "rock", count: 1)
            let tag2 = RealmTag(name: "metal", count: 2)
            realm.add([tag1, tag2])
        }
        let predicate = NSPredicate(format: "count > 1")
        collection.predicate = predicate
        expect(self.collection.count).toEventually(equal(1))

        collection.predicate = nil
        expect(self.collection.count).toEventually(equal(2))
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

        expect(self.collection[0].count).toEventually(equal(3))
        expect(self.collection[0].name).toEventually(equal(self.collection[1].name))
        expect(self.collection[2].name).toEventually(equal("rock"))
    }
}
