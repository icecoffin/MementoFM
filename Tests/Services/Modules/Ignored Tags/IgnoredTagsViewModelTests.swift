//
//  IgnoredTagsViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 09/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import PromiseKit

class IgnoredTagsViewModelTests: XCTestCase {
  class Dependencies: IgnoredTagsViewModel.Dependencies {
    let ignoredTagService: IgnoredTagServiceProtocol
    let artistService: ArtistServiceProtocol

    init(ignoredTagService: IgnoredTagServiceProtocol, artistService: ArtistServiceProtocol) {
      self.ignoredTagService = ignoredTagService
      self.artistService = artistService
    }
  }

  var ignoredTagService: StubIgnoredTagService!
  var artistService: StubArtistService!
  var dependencies: Dependencies!

  override func setUp() {
    ignoredTagService = StubIgnoredTagService()
    artistService = StubArtistService()
    dependencies = Dependencies(ignoredTagService: ignoredTagService, artistService: artistService)
  }

  func testInitWhenIgnoredTagsExist() {
    let defaultIgnoredTagNames = ["tag1", "tag2"]
    ignoredTagService.defaultIgnoredTagNames = defaultIgnoredTagNames

    let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
    ignoredTagService.stubIgnoredTags = ignoredTags

    _ = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)

    expect(self.ignoredTagService.didRequestIgnoredTags).to(beTrue())
    expect(self.ignoredTagService.createdDefaultIgnoredTagNames).to(beEmpty())
  }

  func testInitWithAddingIgnoredTags() {
    let defaultIgnoredTagNames = ["tag1", "tag2"]
    ignoredTagService.defaultIgnoredTagNames = defaultIgnoredTagNames

    _ = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: true)

    expect(self.ignoredTagService.didRequestIgnoredTags).to(beTrue())
    expect(self.ignoredTagService.createdDefaultIgnoredTagNames).to(equal(defaultIgnoredTagNames))
  }

  func testGettingNumberOfIgnoredTags() {
    let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
    ignoredTagService.stubIgnoredTags = ignoredTags

    let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)
    expect(viewModel.numberOfIgnoredTags).to(equal(ignoredTags.count))
  }

  func testGettingCellViewModel() {
    let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
    ignoredTagService.stubIgnoredTags = ignoredTags

    let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)
    let indexPath = IndexPath(row: 0, section: 0)

    let cellViewModel = viewModel.cellViewModel(at: indexPath)
    expect(cellViewModel.text).to(equal(ignoredTags[0].name))

    cellViewModel.onTextChange?("text")
    let updatedCellViewModel = viewModel.cellViewModel(at: indexPath)
    expect(updatedCellViewModel.text).to(equal("text"))
  }

  func testAddingNewIgnoredTag() {
    let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
    ignoredTagService.stubIgnoredTags = ignoredTags

    let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)
    var expectedIndexPath: IndexPath?
    viewModel.onDidAddNewTag = { indexPath in
      expectedIndexPath = indexPath
    }
    viewModel.addNewIgnoredTag()

    expect(expectedIndexPath).toEventually(equal(IndexPath(row: ignoredTags.count, section: 0)))
    expect(viewModel.numberOfIgnoredTags).to(equal(ignoredTags.count + 1))
  }

  func testDeletingIgnoredTag() {
    let ignoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)
    ignoredTagService.stubIgnoredTags = ignoredTags

    let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)
    viewModel.deleteIgnoredTag(at: IndexPath(row: 0, section: 0))
    expect(viewModel.numberOfIgnoredTags).to(equal(ignoredTags.count - 1))
  }

  func testSavingChanges() {
    class StubIgnoredTagsViewModelDelegate: IgnoredTagsViewModelDelegate {
      var didCallDidSaveChanges = false
      func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
        didCallDidSaveChanges = true
      }
    }

    ignoredTagService.stubIgnoredTags = [IgnoredTag(uuid: "uuid1", name: "tag1"),
                                         IgnoredTag(uuid: "uuid2", name: "tag1"),
                                         IgnoredTag(uuid: "uuid3", name: "tag1"),
                                         IgnoredTag(uuid: "uuid4", name: "tag2"),
                                         IgnoredTag(uuid: "uuid5", name: "tag2"),
                                         IgnoredTag(uuid: "uuid6", name: "tag3"),
                                         IgnoredTag(uuid: "uuid7", name: "")]

    let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: false)

    let delegate = StubIgnoredTagsViewModelDelegate()
    viewModel.delegate = delegate

    var didStartSavingChanges = false
    var didFinishSavingChanges = false

    viewModel.onDidStartSavingChanges = {
      didStartSavingChanges = true
    }
    viewModel.onDidFinishSavingChanges = {
      didFinishSavingChanges = true
    }
    viewModel.saveChanges()

    expect(didStartSavingChanges).to(beTrue())
    expect(didFinishSavingChanges).toEventually(beTrue())
    expect(delegate.didCallDidSaveChanges).toEventually(beTrue())

    expect(self.artistService.didCallCalculateTopTagsForAllArtists).toEventually(beTrue())

    let expectedUpdatedIgnoredTags = [IgnoredTag(uuid: "uuid1", name: "tag1"),
                                      IgnoredTag(uuid: "uuid4", name: "tag2"),
                                      IgnoredTag(uuid: "uuid6", name: "tag3")]
    expect(self.ignoredTagService.updatedIgnoredTags).to(equal(expectedUpdatedIgnoredTags))
  }
}
