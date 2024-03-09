//
//  ArtistTopTagsCalculatorTests.swift
//  MementoFM
//
//  Created by Daniel on 05/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

final class ArtistTopTagsCalculatorTests: XCTestCase {
    func test_calculateTopTags_returnsCorrectValue() {
        let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "Tag1"),
                           IgnoredTag(uuid: "uuid3", name: "Tag3")]
        let calculator = ArtistTopTagsCalculator(ignoredTags: ignoredTags, numberOfTopTags: 3)

        let tag1 = Tag(name: "Tag1", count: 1)
        let tag2 = Tag(name: "Tag2", count: 2)
        let tag3 = Tag(name: "Tag3", count: 3)
        let tag4 = Tag(name: "Tag4", count: 4)
        let tag5 = Tag(name: "Tag5", count: 5)
        let tag6 = Tag(name: "Tag6", count: 6)

        let allTags = [tag1, tag2, tag3, tag4, tag5, tag6]
        let artist = ModelFactory.generateArtist().updatingTags(to: allTags, needsTagsUpdate: false)
        let expectedArtist = calculator.calculateTopTags(for: artist)
        XCTAssertEqual(expectedArtist.topTags, [tag6, tag5, tag4])
    }
}
