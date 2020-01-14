//
//  TagTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Mapper
import Nimble

class TagTests: XCTestCase {
    private func sampleTag() -> Tag? {
        guard let json = Utils.json(forResource: "sample_tag", withExtension: "json") as? NSDictionary else {
            return nil
        }

        let mapper = Mapper(JSON: json)
        return try? Tag(map: mapper)
    }

    func testInitializingWithMapper() {
        let tag = sampleTag()
        expect(tag?.count).to(equal(100))
        expect(tag?.name).to(equal("psychedelic rock"))
    }
}
