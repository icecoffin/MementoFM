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

final class RealmTagTests: XCTestCase {
    func test_init_setsCorrectProperties() {
        let realmTag = RealmTag()

        XCTAssertTrue(realmTag.name.isEmpty)
        XCTAssertEqual(realmTag.count, 0)
    }

    func test_fromTransient_setsCorrectProperties() {
        let transientTag = Tag(name: "Tag", count: 10)
        let realmTag = RealmTag.from(transient: transientTag)

        XCTAssertEqual(realmTag.name, transientTag.name)
        XCTAssertEqual(realmTag.count, transientTag.count)
    }

    func test_toTransient_setsCorrectProperties() {
        let realmTag = RealmTag()
        realmTag.name = "Tag"
        realmTag.count = 10
        let transientTag = realmTag.toTransient()

        XCTAssertEqual(transientTag.name, realmTag.name)
        XCTAssertEqual(transientTag.count, realmTag.count)
    }
}
