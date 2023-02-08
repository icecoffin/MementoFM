//
//  IgnoredTagServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 02/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import TransientModels
import PersistenceInterface

final class IgnoredTagServiceTests: XCTestCase {
    private var persistentStore: MockPersistentStore!
    private var ignoredTagService: IgnoredTagService!

    override func setUp() {
        super.setUp()

        persistentStore = MockPersistentStore()
        ignoredTagService = IgnoredTagService(persistentStore: persistentStore)
    }

    override func tearDown() {
        persistentStore = nil
        ignoredTagService = nil

        super.tearDown()
    }

    func test_ignoredTags_callsPersistentStore() {
        let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 5)
        persistentStore.customObjects = ignoredTags

        let expectedIgnoredTags = ignoredTagService.ignoredTags()
        expect(self.persistentStore.objectsPredicate).to(beNil())
        expect(ignoredTags) == expectedIgnoredTags
    }

    func test_createDefaultIgnoredTags_createsTagsAndSavesToPersistentStore() {
        let ignoredTagNames = ["tag1", "tag2"]

        _ = ignoredTagService.createDefaultIgnoredTags(withNames: ignoredTagNames)

        let saveParameters = persistentStore.saveParameters
        let expectedIgnoredTagNames = (saveParameters?.objects as? [IgnoredTag])?.compactMap { $0.name }
        expect(ignoredTagNames) == expectedIgnoredTagNames
        expect(saveParameters?.update) == true
    }

    func test_updateIgnoresTags_deletesOldIgnoredTags_andSavesNewOnes() {
        let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 3)

        _ = ignoredTagService.updateIgnoredTags(ignoredTags)
            .sink(receiveCompletion: { _ in }, receiveValue: { })

        expect(self.persistentStore.didCallDelete) == true
        expect(self.persistentStore.saveParameters?.objects as? [IgnoredTag]) == ignoredTags
    }
}
