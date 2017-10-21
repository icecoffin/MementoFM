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
  var realmService: RealmService!

  override func setUp() {
    super.setUp()
    realmService = RealmService(getRealm: {
      return RealmFactory.inMemoryRealm()
    })
  }

  override func tearDown() {
    realmService = nil
    super.tearDown()
  }

  func testCreatingPersistentRealmService() {
    let service = RealmService.persistent()
    expect(service.getRealm().configuration.inMemoryIdentifier).to(beNil())
  }

  func testCreatingInMemoryRealmService() {
    let service = RealmService.inMemory()
    expect(service.getRealm().configuration.inMemoryIdentifier).toNot(beNil())
  }

  func testSavingSingleObject() {
    let ignoredTag = IgnoredTag(uuid: "uuid", name: "name")
    waitUntil { done in
      self.realmService.save(ignoredTag).then { _ -> Void in
        let expectedIgnoredTag = self.realmService.getRealm().object(ofType: RealmIgnoredTag.self,
                                                                     forPrimaryKey: ignoredTag.uuid)?.toTransient()
        expect(expectedIgnoredTag).to(equal(ignoredTag))
        done()
      }.noError()
    }
  }

  func testSavingMultipleObject() {
    let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                       IgnoredTag(uuid: "uuid2", name: "name2")]
    waitUntil { done in
      self.realmService.save(ignoredTags).then { _ -> Void in
        let expectedIgnoredTags = Array(self.realmService.getRealm().objects(RealmIgnoredTag.self).map({ $0.toTransient() }))
        expect(expectedIgnoredTags).to(equal(ignoredTags))
        done()
        }.noError()
    }
  }

  func testDeletingObjects() {
    let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                       IgnoredTag(uuid: "uuid2", name: "name2")]
    waitUntil { done in
      self.realmService.save(ignoredTags).then { _ -> Promise<Void> in
        let count = self.realmService.getRealm().objects(RealmIgnoredTag.self).count
        expect(count).to(equal(ignoredTags.count))
        return self.realmService.deleteObjects(ofType: IgnoredTag.self).then { _ -> Void in
          let expectedCount = self.realmService.getRealm().objects(RealmIgnoredTag.self).count
          expect(expectedCount).to(equal(0))
          done()
        }
      }.noError()
    }
  }

  func testHavingObjects() {
    expect(self.realmService.hasObjects(ofType: IgnoredTag.self)).to(equal(false))
    let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                       IgnoredTag(uuid: "uuid2", name: "name2")]
    waitUntil { done in
      self.realmService.save(ignoredTags).then { _ -> Void in
        expect(self.realmService.hasObjects(ofType: IgnoredTag.self)).to(equal(true))
        done()
      }.noError()
    }
  }

  func testGettingObjects() {
    let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                       IgnoredTag(uuid: "uuid2", name: "name2")]
    waitUntil { done in
      self.realmService.save(ignoredTags).then { _ -> Void in
        let expectedIgnoredTags = self.realmService.objects(IgnoredTag.self)
        expect(expectedIgnoredTags).to(equal(ignoredTags))
        done()
      }.noError()
    }
  }

  func testGettingObjectsFilteredByPredicate() {
    let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                       IgnoredTag(uuid: "uuid2", name: "name2")]
    waitUntil { done in
      self.realmService.save(ignoredTags).then { _ -> Void in
        let predicate = NSPredicate(format: "name contains[cd] '1'")
        let expectedIgnoredTags = self.realmService.objects(IgnoredTag.self, filteredBy: predicate)
        expect(expectedIgnoredTags).to(equal([IgnoredTag(uuid: "uuid1", name: "name1")]))
        done()
      }.noError()
    }
  }

  func testGettingObjectForExistingPrimaryKey() {
    let ignoredTag = IgnoredTag(uuid: "uuid", name: "name")
    waitUntil { done in
      self.realmService.save(ignoredTag).then { _ -> Void in
        let expectedIgnoredTag = self.realmService.object(ofType: IgnoredTag.self, forPrimaryKey: "uuid")
        expect(expectedIgnoredTag).to(equal(ignoredTag))
        done()
      }.noError()
    }
  }

  func testGettingObjectForMissingPrimaryKey() {
    let missingIgnoredTag = self.realmService.object(ofType: IgnoredTag.self, forPrimaryKey: "test")
    expect(missingIgnoredTag).to(beNil())
  }
}
