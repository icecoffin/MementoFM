//
//  TagsViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 23/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class TagsViewModelTests: XCTestCase {
    class Dependencies: TagsViewModel.Dependencies {
        let tagService: TagServiceProtocol

        init(tagService: TagServiceProtocol) {
            self.tagService = tagService
        }
    }

    class TestTagsViewModelDelegate: TagsViewModelDelegate {
        var selectedTagName: String = ""
        func tagsViewModel(_ viewModel: TagsViewModel, didSelectTagWithName name: String) {
            selectedTagName = name
        }
    }

    var dispatcher: TestDispatcher!
    var tagService: MockTagService!
    var dependencies: Dependencies!

    private func sampleTags() -> [Tag] {
        return [Tag(name: "Tag1", count: 1),
                Tag(name: "Tag1", count: 2),
                Tag(name: "Tag1", count: 3),
                Tag(name: "Tag1", count: 4),
                Tag(name: "Tag2", count: 1),
                Tag(name: "Tag2", count: 2),
                Tag(name: "Tag3", count: 1)]
    }

    override func setUp() {
        dispatcher = TestDispatcher()
        tagService = MockTagService()
        dependencies = Dependencies(tagService: tagService)
    }

    func test_getTags_callsDidUpdateData_withIsEmptyEqualToTrue() {
        let viewModel = TagsViewModel(dependencies: dependencies)
        var expectedIsEmpty = false
        viewModel.didUpdateData = { isEmpty in
            expectedIsEmpty = isEmpty
        }

        viewModel.getTags(backgroundDispatcher: dispatcher, mainDispatcher: dispatcher)

        expect(expectedIsEmpty).toEventually(equal(true))
    }

    func test_getTags_callsDidUpdateData_withIsEmptyEqualToFalse() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let viewModel = TagsViewModel(dependencies: dependencies)
        var expectedIsEmpty = true
        viewModel.didUpdateData = { isEmpty in
            expectedIsEmpty = isEmpty
        }

        viewModel.getTags(backgroundDispatcher: dispatcher, mainDispatcher: dispatcher)

        expect(expectedIsEmpty).toEventually(equal(false))
    }

    func test_numberOfTags_returnsCorrectValue() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let viewModel = TagsViewModel(dependencies: dependencies)

        viewModel.getTags(backgroundDispatcher: dispatcher, mainDispatcher: dispatcher)

        var expectedNumberOfTags = 0
        viewModel.didUpdateData = { [unowned viewModel] _ in
            expectedNumberOfTags = viewModel.numberOfTags
        }
        expect(expectedNumberOfTags).toEventually(equal(2))
    }

    func func_cellViewModelAtIndexPath_returnsCorrectValue() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let viewModel = TagsViewModel(dependencies: dependencies)
        var expectedCellViewModel: TagCellViewModel?
        viewModel.didUpdateData = { [unowned viewModel] _ in
            let indexPath = IndexPath(row: 1, section: 0)
            expectedCellViewModel = viewModel.cellViewModel(at: indexPath)
        }

        viewModel.getTags(backgroundDispatcher: dispatcher, mainDispatcher: dispatcher)

        expect(expectedCellViewModel?.name).toEventually(equal("Tag2"))
    }

    func test_selectTagAtIndexPath_notifiesDelegate() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let delegate = TestTagsViewModelDelegate()
        let viewModel = TagsViewModel(dependencies: dependencies)
        viewModel.delegate = delegate
        viewModel.didUpdateData = { [unowned viewModel] _ in
            let indexPath = IndexPath(row: 1, section: 0)
            viewModel.selectTag(at: indexPath)
        }

        viewModel.getTags(backgroundDispatcher: dispatcher, mainDispatcher: dispatcher)

        expect(delegate.selectedTagName).toEventually(equal("Tag2"))
    }

    func test_performSearch_filtersTagsBasedOnSearchText() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let viewModel = TagsViewModel(dependencies: dependencies)
        var expectedNumberOfTags = 0

        var didGetTags: ((Bool) -> Void)?
        var didPerformSearch: ((Bool) -> Void)?

        didGetTags = { [unowned viewModel] _ in
            viewModel.didUpdateData = didPerformSearch
            viewModel.performSearch(withText: "1")
        }

        didPerformSearch = { [unowned viewModel] _ in
            expectedNumberOfTags = viewModel.numberOfTags
        }

        viewModel.didUpdateData = didGetTags
        viewModel.getTags(backgroundDispatcher: dispatcher, mainDispatcher: dispatcher)

        expect(expectedNumberOfTags).toEventually(equal(1))
    }

    func test_cancelSearch_returnsAllTagsWithoutFiltering() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let viewModel = TagsViewModel(dependencies: dependencies)
        var expectedNumberOfTags = 0

        var didGetTags: ((Bool) -> Void)?
        var didPerformSearch: ((Bool) -> Void)?
        var didCancelSearch: ((Bool) -> Void)?

        didGetTags = { [unowned viewModel] _ in
            viewModel.didUpdateData = didPerformSearch
            viewModel.performSearch(withText: "1")
        }

        didPerformSearch = { [unowned viewModel] _ in
            viewModel.didUpdateData = didCancelSearch
            viewModel.cancelSearch()
        }

        didCancelSearch = { [unowned viewModel] _ in
            expectedNumberOfTags = viewModel.numberOfTags
        }

        viewModel.didUpdateData = didGetTags
        viewModel.getTags(backgroundDispatcher: dispatcher, mainDispatcher: dispatcher)

        expect(expectedNumberOfTags).toEventually(equal(2))
    }
}
