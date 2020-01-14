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
import Nimble

class IgnoredTagTests: XCTestCase {
    func testUpdatingName() {
        let ignoredTag = IgnoredTag(uuid: "uuid", name: "name")
        let updatedIgnoredTag = ignoredTag.updatingName("new name")
        expect(updatedIgnoredTag.uuid).to(equal(ignoredTag.uuid))
        expect(updatedIgnoredTag.name).to(equal("new name"))
    }
}
