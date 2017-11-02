//
//  IgnoredTagServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 02/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import PromiseKit

class IgnoredTagServiceTests: XCTestCase {
  var realmService: RealmService!
  var ignoredTagService: IgnoredTagService!

  override func setUp() {
    super.setUp()

    realmService = RealmService(getRealm: {
      return RealmFactory.inMemoryRealm()
    })
    ignoredTagService = IgnoredTagService(realmService: realmService)
  }

  override func tearDown() {
    realmService = nil
    ignoredTagService = nil
    super.tearDown()
  }

  func testGettingIgnoredTags() {
    waitUntil { done in
      let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 5)
      self.realmService.save(ignoredTags).then { _ -> Void in
        let expectedIgnoredTags = self.ignoredTagService.ignoredTags()
        expect(expectedIgnoredTags).to(equal(ignoredTags))
        done()
      }.noError()
    }
  }

  func testCreatingDefaultIgnoredTags() {
    waitUntil { done in
      let ignoredTagNames = ["tag1", "tag2"]
      self.ignoredTagService.createDefaultIgnoredTags(withNames: ignoredTagNames).then { _ -> Void in
        let expectedIgnoredTagNames = self.realmService.objects(IgnoredTag.self).map { $0.name }
        expect(expectedIgnoredTagNames).to(equal(ignoredTagNames))
        done()
      }.noError()
    }
  }

  func testUpdatingIgnoredTags() {
    waitUntil { done in
      let ignoredTags1 = ModelFactory.generateIgnoredTags(inAmount: 5)
      let ignoredTags2 = ModelFactory.generateIgnoredTags(inAmount: 10)
      self.realmService.save(ignoredTags1).then { _ -> Promise<Void> in
        return self.ignoredTagService.updateIgnoredTags(ignoredTags2)
      }.then { _ -> Void in
        let expectedIgnoredTags = self.ignoredTagService.ignoredTags()
        expect(expectedIgnoredTags).to(equal(ignoredTags2))
        done()
      }.noError()
    }
  }
}
