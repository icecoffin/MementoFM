//
//  TopTagsListTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Mapper
import Nimble

class TopTagsListTests: XCTestCase {
    func test_initWithMap_setsCorrectProperties() {
        let topTagsList = makeSampleTopTagsList(fileName: "sample_top_tags_list_short")

        expect(topTagsList?.tags.count) == 4
    }

    func test_initWithMap_limitsTopTagsCount() {
        let topTagsList = makeSampleTopTagsList(fileName: "sample_top_tags_list")

        expect(topTagsList?.tags.count) == TopTagsList.maxTagCount
    }

    private func makeSampleTopTagsList(fileName: String) -> TopTagsList? {
        guard let json = Utils.json(forResource: fileName, withExtension: "json") as? NSDictionary else {
            return nil
        }

        let mapper = Mapper(JSON: json)
        return try? TopTagsList(map: mapper)
    }
}
