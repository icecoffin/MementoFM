//
//  IgnoredTagServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 02/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

final class IgnoredTagServiceTests: XCTestCase {
    private var ignoredTagStore: MockIgnoredTagStore!
    private var ignoredTagService: IgnoredTagService!

    override func setUp() {
        super.setUp()

        ignoredTagStore = MockIgnoredTagStore()
        ignoredTagService = IgnoredTagService(ignoredTagStore: ignoredTagStore)
    }

    override func tearDown() {
        ignoredTagStore = nil
        ignoredTagService = nil

        super.tearDown()
    }

    func test_ignoredTags_callsPersistentStore() {
        let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 5)
        ignoredTagStore.customIgnoredTags = ignoredTags

        let expectedIgnoredTags = ignoredTagService.ignoredTags()
        XCTAssertEqual(ignoredTagStore.fetchAllCallCount, 1)
        XCTAssertEqual(ignoredTags, expectedIgnoredTags)
    }

    func test_createDefaultIgnoredTags_createsTagsAndSavesToPersistentStore() {
        let ignoredTagNames = ["tag1", "tag2"]

        _ = ignoredTagService.createDefaultIgnoredTags(withNames: ignoredTagNames)

        let expectedIgnoredTagNames = (ignoredTagStore.saveParameters)?.compactMap { $0.name }
        XCTAssertEqual(ignoredTagNames, expectedIgnoredTagNames)
        XCTAssertEqual(ignoredTagStore.saveCallCount, 1)
    }

    func test_updateIgnoresTags_deletesOldIgnoredTags_andSavesNewOnes() {
        let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 3)

        _ = ignoredTagService.updateIgnoredTags(ignoredTags)
            .sink(receiveCompletion: { _ in }, receiveValue: { })

        XCTAssertEqual(ignoredTagStore.overwriteCallCount, 1)
        XCTAssertEqual(ignoredTagStore.overwriteParameters, ignoredTags)
    }
}
