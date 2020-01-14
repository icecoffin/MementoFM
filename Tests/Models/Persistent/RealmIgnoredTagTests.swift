//
//  RealmIgnoredTagTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import RealmSwift
import Nimble

class RealmIgnoredTagTests: XCTestCase {
    func testPrimaryKeyIsSet() {
        expect(RealmIgnoredTag.primaryKey()).to(equal("uuid"))
    }

    func testPropertiesAreSetCorrectlyAfterInit() {
        let realmIgnoredTag = RealmIgnoredTag()
        expect(UUID(uuidString: realmIgnoredTag.uuid)).toNot(beNil())
        expect(realmIgnoredTag.name).to(beEmpty())
    }

    func testCreatingFromTransient() {
        let transientIgnoredTag = IgnoredTag(uuid: "uuid", name: "Tag")
        let realmIgnoredTag = RealmIgnoredTag.from(transient: transientIgnoredTag)
        expect(realmIgnoredTag.uuid).to(equal(transientIgnoredTag.uuid))
        expect(realmIgnoredTag.name).to(equal(transientIgnoredTag.name))
    }

    func testConvertingToTransient() {
        let realmIgnoredTag = RealmIgnoredTag()
        realmIgnoredTag.uuid = "uuid"
        realmIgnoredTag.name = "Tag"
        let transientIgnoredTag = realmIgnoredTag.toTransient()
        expect(transientIgnoredTag.uuid).to(equal(realmIgnoredTag.uuid))
        expect(transientIgnoredTag.name).to(equal(realmIgnoredTag.name))
    }
}
