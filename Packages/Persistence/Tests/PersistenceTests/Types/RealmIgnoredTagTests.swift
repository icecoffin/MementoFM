//
//  RealmIgnoredTagTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
import RealmSwift
import Nimble
import TransientModels
@testable import Persistence
import InfrastructureTestingUtilities

final class RealmIgnoredTagTests: XCTestCase {
    func test_primaryKey_isSet() {
        expect(RealmIgnoredTag.primaryKey()) == "uuid"
    }

    func test_init_setsCorrectProperties() {
        let realmIgnoredTag = RealmIgnoredTag()

        expect(UUID(uuidString: realmIgnoredTag.uuid)).toNot(beNil())
        expect(realmIgnoredTag.name).to(beEmpty())
    }

    func test_fromTransient_setsCorrectProperties() {
        let transientIgnoredTag = IgnoredTag(uuid: "uuid", name: "Tag")
        let realmIgnoredTag = RealmIgnoredTag.from(transient: transientIgnoredTag)

        expect(realmIgnoredTag.uuid) == transientIgnoredTag.uuid
        expect(realmIgnoredTag.name) == transientIgnoredTag.name
    }

    func test_toTransient_setsCorrectProperties() {
        let realmIgnoredTag = RealmIgnoredTag()
        realmIgnoredTag.uuid = "uuid"
        realmIgnoredTag.name = "Tag"
        let transientIgnoredTag = realmIgnoredTag.toTransient()

        expect(transientIgnoredTag.uuid) == realmIgnoredTag.uuid
        expect(transientIgnoredTag.name) == realmIgnoredTag.name
    }
}
