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
}
