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
import Combine
import CombineSchedulers

final class TagsViewModelTests: XCTestCase {
    private final class Dependencies: TagsViewModel.Dependencies {
        let tagService: TagServiceProtocol

        init(tagService: TagServiceProtocol) {
            self.tagService = tagService
        }
    }

    private final class TestTagsViewModelDelegate: TagsViewModelDelegate {
        var selectedTagName: String = ""
        func tagsViewModel(_ viewModel: TagsViewModel, didSelectTagWithName name: String) {
            selectedTagName = name
        }
    }

    private var scheduler: AnySchedulerOf<DispatchQueue>!
    private var tagService: MockTagService!
    private var dependencies: Dependencies!
    private var cancelBag: Set<AnyCancellable>!

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
        super.setUp()

        scheduler = .immediate
        tagService = MockTagService()
        dependencies = Dependencies(tagService: tagService)
        cancelBag = .init()
    }

    override func tearDown() {
        scheduler = nil
        tagService = nil
        dependencies = nil
        cancelBag = nil

        super.tearDown()
    }

    func test_getTags_callsDidUpdateData_withIsEmptyEqualToTrue() {
        let viewModel = makeTagsViewModel()
        var expectedIsEmpty = false
        viewModel.didUpdateData
            .sink(receiveValue: { isEmpty in
                expectedIsEmpty = isEmpty
            })
            .store(in: &cancelBag)

        viewModel.getTags()

        expect(expectedIsEmpty) == true
    }

    func test_getTags_callsDidUpdateData_withIsEmptyEqualToFalse() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let viewModel = makeTagsViewModel()
        var expectedIsEmpty = true
        viewModel.didUpdateData
            .sink(receiveValue: { isEmpty in
                expectedIsEmpty = isEmpty
            })
            .store(in: &cancelBag)

        viewModel.getTags()

        expect(expectedIsEmpty) == false
    }

    func test_numberOfTags_returnsCorrectValue() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let viewModel = makeTagsViewModel()
        var expectedNumberOfTags = 0
        viewModel.didUpdateData
            .sink(receiveValue: { [unowned viewModel] _ in
                expectedNumberOfTags = viewModel.numberOfTags
            })
            .store(in: &cancelBag)

        viewModel.getTags()

        expect(expectedNumberOfTags) == 2
    }

    func func_cellViewModelAtIndexPath_returnsCorrectValue() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let viewModel = makeTagsViewModel()
        var expectedCellViewModel: TagCellViewModel?
        viewModel.didUpdateData
            .sink(receiveValue: { [unowned viewModel] _ in
                let indexPath = IndexPath(row: 1, section: 0)
                expectedCellViewModel = viewModel.cellViewModel(at: indexPath)
            })
            .store(in: &cancelBag)

        viewModel.getTags()

        expect(expectedCellViewModel?.name) == "Tag2"
    }

    func test_selectTagAtIndexPath_notifiesDelegate() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let delegate = TestTagsViewModelDelegate()
        let viewModel = makeTagsViewModel()
        viewModel.delegate = delegate
        viewModel.didUpdateData
            .sink(receiveValue: { [unowned viewModel] _ in
                let indexPath = IndexPath(row: 1, section: 0)
                viewModel.selectTag(at: indexPath)
            })
            .store(in: &cancelBag)

        viewModel.getTags()

        expect(delegate.selectedTagName) == "Tag2"
    }

    func test_performSearch_filtersTagsBasedOnSearchText() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let viewModel = makeTagsViewModel()
        var expectedNumberOfTags = 0
        viewModel.didUpdateData
            .sink { [unowned viewModel] _ in
                expectedNumberOfTags = viewModel.numberOfTags
            }
            .store(in: &cancelBag)

        viewModel.getTags()
        viewModel.performSearch(withText: "1")

        expect(expectedNumberOfTags) == 1
    }

    func test_cancelSearch_returnsAllTagsWithoutFiltering() {
        let tags = sampleTags()
        tagService.customTopTags = tags
        let viewModel = makeTagsViewModel()
        var expectedNumberOfTags = 0
        viewModel.didUpdateData
            .sink { [unowned viewModel] _ in
                expectedNumberOfTags = viewModel.numberOfTags
            }
            .store(in: &cancelBag)

        viewModel.getTags()
        viewModel.performSearch(withText: "1")
        viewModel.cancelSearch()

        expect(expectedNumberOfTags) == 2
    }

    private func makeTagsViewModel() -> TagsViewModel {
        return TagsViewModel(dependencies: dependencies,
                             backgroundScheduler: scheduler,
                             mainScheduler: scheduler)
    }
}
