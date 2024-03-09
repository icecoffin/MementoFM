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

final class RealmIgnoredTagTests: XCTestCase {
    func test_primaryKey_isSet() {
        XCTAssertEqual(RealmIgnoredTag.primaryKey(), "uuid")
    }

    func test_init_setsCorrectProperties() {
        let realmIgnoredTag = RealmIgnoredTag()

        XCTAssertNotNil(UUID(uuidString: realmIgnoredTag.uuid))
        XCTAssertTrue(realmIgnoredTag.name.isEmpty)
    }

    func test_fromTransient_setsCorrectProperties() {
        let transientIgnoredTag = IgnoredTag(uuid: "uuid", name: "Tag")
        let realmIgnoredTag = RealmIgnoredTag.from(transient: transientIgnoredTag)

        XCTAssertEqual(realmIgnoredTag.uuid, transientIgnoredTag.uuid)
        XCTAssertEqual(realmIgnoredTag.name, transientIgnoredTag.name)
    }

    func test_toTransient_setsCorrectProperties() {
        let realmIgnoredTag = RealmIgnoredTag()
        realmIgnoredTag.uuid = "uuid"
        realmIgnoredTag.name = "Tag"
        let transientIgnoredTag = realmIgnoredTag.toTransient()

        XCTAssertEqual(transientIgnoredTag.uuid, realmIgnoredTag.uuid)
        XCTAssertEqual(transientIgnoredTag.name, realmIgnoredTag.name)
    }
}
