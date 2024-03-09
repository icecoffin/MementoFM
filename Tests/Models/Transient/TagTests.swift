//
//  TagTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

final class TagTests: XCTestCase {
    func test_decodeFromJSON_setsCorrectProperties() {
        let tag = makeSampleTag()

        XCTAssertEqual(tag?.count, 100)
        XCTAssertEqual(tag?.name, "psychedelic rock")
    }

    // MARK: - Helpers

    private func makeSampleTag() -> Tag? {
        guard let data = Utils.data(fromResource: "sample_tag", withExtension: "json") else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(Tag.self, from: data)
    }
}
