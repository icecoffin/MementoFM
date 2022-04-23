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

final class RealmTagTests: XCTestCase {
    func test_init_setsCorrectProperties() {
        let realmTag = RealmTag()

        expect(realmTag.name).to(beEmpty())
        expect(realmTag.count) == 0
    }

    func test_fromTransient_setsCorrectProperties() {
        let transientTag = Tag(name: "Tag", count: 10)
        let realmTag = RealmTag.from(transient: transientTag)

        expect(realmTag.name) == transientTag.name
        expect(realmTag.count) == transientTag.count
    }

    func test_toTransient_setsCorrectProperties() {
        let realmTag = RealmTag()
        realmTag.name = "Tag"
        realmTag.count = 10
        let transientTag = realmTag.toTransient()

        expect(transientTag.name) == realmTag.name
        expect(transientTag.count) == realmTag.count
    }
}
