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
  var collection: RealmMappedCollection<RealmTag, Tag>!

  override func setUp() {
    super.setUp()
    realm = RealmFactory.inMemoryRealm()
    collection = RealmMappedCollection(realm: realm, sortDescriptors: [], transform: { realmTag in
      return realmTag.toTransient()
    })
  }

  override func tearDown() {
    realm = nil
    collection = nil
    super.tearDown()
  }

  func testCount() {
    try? realm.write {
      let tag = RealmTag()
      realm.add(tag)
    }
    expect(self.collection.count).to(equal(1))
  }

  func testIsEmptyReturnsTrueWhenEmpty() {
    expect(self.collection.isEmpty).to(beTrue())
  }

  func testIsEmptyReturnsFalseWhenNotEmpty() {
    try? realm.write {
      let tag = RealmTag()
      realm.add(tag)
    }
    expect(self.collection.isEmpty).to(beFalse())
  }

  func testGettingItemAtIndex() {
    try? realm.write {
      let tag1 = RealmTag(name: "rock", count: 1)
      let tag2 = RealmTag(name: "metal", count: 2)
      realm.add([tag1, tag2])
    }

    let secondTag = collection[1]
    expect(secondTag.name).to(equal("metal"))
    expect(secondTag.count).to(equal(2))
  }

  func testSettingPredicate() {
    try? realm.write {
      let tag1 = RealmTag(name: "rock", count: 1)
      let tag2 = RealmTag(name: "metal", count: 2)
      realm.add([tag1, tag2])
    }
    let predicate = NSPredicate(format: "count > 1")
    collection.predicate = predicate
    expect(self.collection.count).to(equal(1))

    collection.predicate = nil
    expect(self.collection.count).to(equal(2))
  }

  func testSettingSortDescriptors() {
    try? realm.write {
      let tag1 = RealmTag(name: "rock", count: 1)
      let tag2 = RealmTag(name: "indie", count: 2)
      let tag3 = RealmTag(name: "indie", count: 3)
      realm.add([tag1, tag2, tag3])
    }
    let sortDescriptors = [SortDescriptor(keyPath: "name", ascending: true),
                           SortDescriptor(keyPath: "count", ascending: false)]
    collection.sortDescriptors = sortDescriptors

    expect(self.collection[0].count).to(equal(3))
    expect(self.collection[0].name).to(equal(self.collection[1].name))
    expect(self.collection[2].name).to(equal("rock"))
  }

  func testUpdatesNotifications() {
    let sortDescriptors = [SortDescriptor(keyPath: "name", ascending: true),
                           SortDescriptor(keyPath: "count", ascending: true)]
    collection.sortDescriptors = sortDescriptors

    // [("metal", 2)", ("rock", 1"]
    try? realm.write {
      let tag1 = RealmTag(name: "rock", count: 1)
      let tag2 = RealmTag(name: "metal", count: 2)
      realm.add([tag1, tag2])
    }

    waitUntil { done in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.collection.notificationBlock = { changes in
          switch changes {
          case .update(_, let deletions, let insertions, let modifications):
            expect(deletions).to(equal([0]))
            expect(insertions).to(equal([0]))
            expect(modifications).to(equal([1]))
            done()
          default:
            fail()
          }
        }

        try? self.realm.write {
          // [("metal", 2), ("rock", 5)]
          let tag1 = self.realm.objects(RealmTag.self).filter("name == \"rock\"").first
          tag1?.count = 5
          // [("rock", 5)]
          if let tag2 = self.realm.objects(RealmTag.self).filter("name == \"metal\"").first {
            self.realm.delete(tag2)
          }
          // [("electronic", 3), ("rock", 5)]
          let tag3 = RealmTag(name: "electronic", count: 3)
          self.realm.add(tag3)
        }
      }
    }
  }
}
