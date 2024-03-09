//
//  IgnoredTagTests.swift
//  MementoFM
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import XCTest
@testable import MementoFM

final class IgnoredTagTests: XCTestCase {
    func test_updatingName_setsCorrectProperties() {
        let ignoredTag = IgnoredTag(uuid: "uuid", name: "name")

        let updatedIgnoredTag = ignoredTag.updatingName("new name")

        XCTAssertEqual(updatedIgnoredTag.uuid, ignoredTag.uuid)
        XCTAssertEqual(updatedIgnoredTag.name, "new name")
    }
}
