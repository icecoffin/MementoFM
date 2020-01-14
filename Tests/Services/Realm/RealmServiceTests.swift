//
//  RealmServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 12/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
import Nimble
@testable import MementoFM
import RealmSwift
import PromiseKit

class RealmServiceTests: XCTestCase {
  var realm: Realm!
  var realmService: RealmService!

  override func setUp() {
    super.setUp()

    realm = RealmFactory.inMemoryRealm()
    realmService = RealmService(getRealm: {
      return RealmFactory.inMemoryRealm()
    }, backgroundDispatcher: TestDispatcher(), mainDispatcher: TestDispatcher())
  }

  override func tearDown() {
    realm = nil
    realmService = nil
    super.tearDown()
  }

  func test_saveSingleObject_writesToRealm() {
    waitUntil { done in
      let ignoredTag = IgnoredTag(uuid: "uuid", name: "name")
      self.realmService.save(ignoredTag).done { _ in
        let expectedIgnoredTag = self.realm.object(ofType: RealmIgnoredTag.self,
                                                   forPrimaryKey: ignoredTag.uuid)?.toTransient()
        expect(expectedIgnoredTag).to(equal(ignoredTag))
        done()
      }.noError()
    }
  }

  func test_saveMultipleObjets_writesToRealm() {
    waitUntil { done in
      let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                         IgnoredTag(uuid: "uuid2", name: "name2")]
      self.realmService.save(ignoredTags).done { _ in
        let expectedIgnoredTags = Array(self.realm.objects(RealmIgnoredTag.self).map({ $0.toTransient() }))
        expect(expectedIgnoredTags).to(equal(ignoredTags))
        done()
        }.noError()
    }
  }

  func test_deleteObjects_deletesFromRealm() {
    waitUntil { done in
      let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                         IgnoredTag(uuid: "uuid2", name: "name2")]
      self.realmService.save(ignoredTags).then { _ -> Promise<Void> in
        let count = self.realm.objects(RealmIgnoredTag.self).count
        expect(count).to(equal(ignoredTags.count))
        return self.realmService.deleteObjects(ofType: IgnoredTag.self).done { _ in
          let expectedCount = self.realm.objects(RealmIgnoredTag.self).count
          expect(expectedCount).to(equal(0))
          done()
        }
      }.noError()
    }
  }

  func test_objects_returnsObjectsFromRealm() {
    waitUntil { done in
      let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                         IgnoredTag(uuid: "uuid2", name: "name2")]
      self.realmService.save(ignoredTags).done { _ in
        let expectedIgnoredTags = self.realmService.objects(IgnoredTag.self)
        expect(expectedIgnoredTags).to(equal(ignoredTags))
        done()
      }.noError()
    }
  }

  func test_objects_returnsObjectsFromRealm_filteredByPredicate() {
    waitUntil { done in
      let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                         IgnoredTag(uuid: "uuid2", name: "name2")]
      self.realmService.save(ignoredTags).done { _ in
        let predicate = NSPredicate(format: "name contains[cd] '1'")
        let expectedIgnoredTags = self.realmService.objects(IgnoredTag.self, filteredBy: predicate)
        expect(expectedIgnoredTags).to(equal([IgnoredTag(uuid: "uuid1", name: "name1")]))
        done()
      }.noError()
    }
  }

  func test_objectForPrimaryKey_returnsExistingObject() {
    waitUntil { done in
      let ignoredTag = IgnoredTag(uuid: "uuid", name: "name")
      self.realmService.save(ignoredTag).done { _ in
        let expectedIgnoredTag = self.realmService.object(ofType: IgnoredTag.self, forPrimaryKey: "uuid")
        expect(expectedIgnoredTag).to(equal(ignoredTag))
        done()
      }.noError()
    }
  }

  func test_objectForPrimaryKey_returnsNilForMissingKey() {
    let missingIgnoredTag = self.realmService.object(ofType: IgnoredTag.self, forPrimaryKey: "test")
    expect(missingIgnoredTag).to(beNil())
  }

  func test_mappedCollection_createsMappedCollectionWithCorrectParameters() {
    let predicate = NSPredicate(format: "name contains[cd] '1'")
    let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    let mappedCollection: AnyPersistentMappedCollection<IgnoredTag>
    mappedCollection = realmService.mappedCollection(filteredUsing: predicate, sortedBy: sortDescriptors)
    expect(mappedCollection.predicate).to(equal(predicate))
    expect(mappedCollection.sortDescriptors).to(equal(sortDescriptors))
  }
}
