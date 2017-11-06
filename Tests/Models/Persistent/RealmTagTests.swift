//
//  RealmTagTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import RealmSwift
import Nimble

class RealmTagTests: XCTestCase {
  func testPropertiesAreSetCorrectlyAfterInit() {
    let realmTag = RealmTag()
    expect(realmTag.name).to(beEmpty())
    expect(realmTag.count).to(equal(0))
  }

  func testCreatingFromTransient() {
    let transientTag = Tag(name: "Tag", count: 10)
    let realmTag = RealmTag.from(transient: transientTag)
    expect(realmTag.name).to(equal(transientTag.name))
    expect(realmTag.count).to(equal(transientTag.count))
  }

  func testConvertingToTransient() {
    let realmTag = RealmTag()
    realmTag.name = "Tag"
    realmTag.count = 10
    let transientTag = realmTag.toTransient()
    expect(transientTag.name).to(equal(realmTag.name))
    expect(transientTag.count).to(equal(realmTag.count))
  }
}
