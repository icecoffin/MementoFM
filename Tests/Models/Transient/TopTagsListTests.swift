//
//  TopTagsListTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

final class TopTagsListTests: XCTestCase {
    func test_decodeFromJSON_setsCorrectProperties() {
        let topTagsList = makeSampleTopTagsList(fileName: "sample_top_tags_list")

        expect(topTagsList?.tags.count) == 47
    }

    // MARK: - Helpers

    private func makeSampleTopTagsList(fileName: String) -> TopTagsList? {
        guard let data = Utils.data(fromResource: fileName, withExtension: "json") else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(TopTagsList.self, from: data)
    }
}
