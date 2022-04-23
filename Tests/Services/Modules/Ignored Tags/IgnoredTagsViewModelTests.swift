//
//  IgnoredTagsViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 09/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
import Nimble
import Combine
@testable import MementoFM

class IgnoredTagsViewModelTests: XCTestCase {
    class Dependencies: IgnoredTagsViewModel.Dependencies {
        let ignoredTagService: IgnoredTagServiceProtocol
        let artistService: ArtistServiceProtocol

        init(ignoredTagService: IgnoredTagServiceProtocol, artistService: ArtistServiceProtocol) {
            self.ignoredTagService = ignoredTagService
            self.artistService = artistService
        }
    }

    class TestIgnoredTagsViewModelDelegate: IgnoredTagsViewModelDelegate {
        var didCallDidSaveChanges = false

        func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
            didCallDidSaveChanges = true
        }
    }

    private var ignoredTagService: MockIgnoredTagService!
    private var artistService: MockArtistService!
    private var dependencies: Dependencies!
    private var cancelBag: Set<AnyCancellable>!

    override func setUp() {
        ignoredTagService = MockIgnoredTagService()
        artistService = MockArtistService()
        dependencies = Dependencies(ignoredTagService: ignoredTagService, artistService: artistService)
        cancelBag = .init()
    }

    func test_init_doesNotCreateDefaultIgnoredTags_whenShouldAddDefaultTagsIsFalse() {
        let defaultIgnoredTagNames = ["tag1", "tag2"]
        ignoredTagService.defaultIgnoredTagNames = defaultIgnoredTagNames

        let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
        ignoredTagService.customIgnoredTags = ignoredTags

        _ = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)

        expect(self.ignoredTagService.didRequestIgnoredTags) == true
        expect(self.ignoredTagService.createdDefaultIgnoredTagNames).to(beEmpty())
    }

    func test_init_createsDefaultIgnoredTags_whenShouldAddDefaultTagsIsTrue() {
        let defaultIgnoredTagNames = ["tag1", "tag2"]
        ignoredTagService.defaultIgnoredTagNames = defaultIgnoredTagNames

        _ = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: true)

        expect(self.ignoredTagService.didRequestIgnoredTags) == true
        expect(self.ignoredTagService.createdDefaultIgnoredTagNames) == defaultIgnoredTagNames
    }

    func test_numberOfIgnoredTags_returnsCorrectValue() {
        let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
        ignoredTagService.customIgnoredTags = ignoredTags

        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)

        expect(viewModel.numberOfIgnoredTags) == ignoredTags.count
    }

    func test_cellViewModelAtIndexPath_returnsCorrectValue() {
        let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
        ignoredTagService.customIgnoredTags = ignoredTags

        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)
        let indexPath = IndexPath(row: 0, section: 0)

        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        expect(cellViewModel.text) == ignoredTags[0].name

        cellViewModel.onTextChange?("text")
        let updatedCellViewModel = viewModel.cellViewModel(at: indexPath)
        expect(updatedCellViewModel.text) == "text"
    }

    func test_cellViewModelAtIndexPath_returnsNewValueOnTextChange() {
        let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
        ignoredTagService.customIgnoredTags = ignoredTags

        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)
        let indexPath = IndexPath(row: 0, section: 0)

        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        cellViewModel.onTextChange?("text")

        let updatedCellViewModel = viewModel.cellViewModel(at: indexPath)

        expect(updatedCellViewModel.text) == "text"
    }

    func test_addNewIgnoredTag_callsDidAddNewTag() {
        let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
        ignoredTagService.customIgnoredTags = ignoredTags

        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)

        var expectedIndexPath: IndexPath?
        viewModel.didAddNewTag
            .sink(receiveValue: { indexPath in
                expectedIndexPath = indexPath
            })
            .store(in: &cancelBag)

        viewModel.addNewIgnoredTag()

        expect(expectedIndexPath) == IndexPath(row: ignoredTags.count, section: 0)
    }

    func test_addNewIgnoredTag_increasesNumberOfIgnoredTags() {
        let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
        ignoredTagService.customIgnoredTags = ignoredTags

        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)

        viewModel.addNewIgnoredTag()

        expect(viewModel.numberOfIgnoredTags) == ignoredTags.count + 1
    }

    func test_deleteIgnoredTagAtIndexPath_decreasesNumberOfIgnoredTags() {
        let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
        ignoredTagService.customIgnoredTags = ignoredTags

        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)

        viewModel.deleteIgnoredTag(at: IndexPath(row: 0, section: 0))

        expect(viewModel.numberOfIgnoredTags) == ignoredTags.count - 1
    }

    func test_saveChanges_startsAndFinishesSavingChanges() {
        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)

        var savingChangesStates: [Bool] = []

        viewModel.isSavingChanges
            .sink(receiveValue: { isSaving in
                savingChangesStates.append(isSaving)
            })
            .store(in: &cancelBag)

        viewModel.saveChanges()

        expect(savingChangesStates) == [true, false]
    }

    func test_saveChanges_notifiesDelegateOnSuccess() {
        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)

        let delegate = TestIgnoredTagsViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.saveChanges()

        expect(delegate.didCallDidSaveChanges) == true
    }

    func test_saveChanges_callsArtistService() {
        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)

        viewModel.saveChanges()

        expect(self.artistService.didCallCalculateTopTagsForAllArtists) == true
    }

    func test_saveChanges_updatesIgnoredTags() {
        ignoredTagService.customIgnoredTags = [IgnoredTag(uuid: "uuid1", name: "tag1"),
                                               IgnoredTag(uuid: "uuid2", name: "tag1"),
                                               IgnoredTag(uuid: "uuid3", name: "tag1"),
                                               IgnoredTag(uuid: "uuid4", name: "tag2"),
                                               IgnoredTag(uuid: "uuid5", name: "tag2"),
                                               IgnoredTag(uuid: "uuid6", name: "tag3"),
                                               IgnoredTag(uuid: "uuid7", name: "")]

        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)

        viewModel.saveChanges()

        let expectedUpdatedIgnoredTags = [IgnoredTag(uuid: "uuid1", name: "tag1"),
                                          IgnoredTag(uuid: "uuid4", name: "tag2"),
                                          IgnoredTag(uuid: "uuid6", name: "tag3")]
        expect(self.ignoredTagService.updatedIgnoredTags) == expectedUpdatedIgnoredTags
    }
}
