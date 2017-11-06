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
    let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 5)

    waitUntil { done in
      self.realmService.save(ignoredTags).then { _ -> Void in
        let expectedIgnoredTags = self.ignoredTagService.ignoredTags()
        expect(expectedIgnoredTags).to(equal(ignoredTags))
        done()
      }.noError()
    }
  }

  func testCreatingDefaultIgnoredTags() {
    let ignoredTagNames = ["tag1", "tag2"]

    waitUntil { done in
      self.ignoredTagService.createDefaultIgnoredTags(withNames: ignoredTagNames).then { _ -> Void in
        let expectedIgnoredTagNames = self.realmService.objects(IgnoredTag.self).map { $0.name }
        expect(expectedIgnoredTagNames).to(equal(ignoredTagNames))
        done()
      }.noError()
    }
  }

  func testUpdatingIgnoredTags() {
    let originalIgnoredTags = ModelFactory.generateIgnoredTags(inAmount: 5)
    let updatedIgnoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)

    waitUntil { done in
      firstly {
        self.realmService.save(originalIgnoredTags)
      }.then {
        self.ignoredTagService.updateIgnoredTags(updatedIgnoredTags)
      }.then { _ -> Void in
        let expectedIgnoredTags = self.ignoredTagService.ignoredTags()
        expect(expectedIgnoredTags).to(equal(updatedIgnoredTags))
        done()
      }.noError()
    }
  }
}
