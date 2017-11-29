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
import PromiseKit

class TagsViewModelTests: XCTestCase {
  class Dependencies: TagsViewModel.Dependencies {
    let tagService: TagServiceProtocol

    init(tagService: TagServiceProtocol) {
      self.tagService = tagService
    }
  }

  var tagService: StubTagService!
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
    tagService = StubTagService()
    dependencies = Dependencies(tagService: tagService)
  }

  func testGettingTagsWhenEmpty() {
    let viewModel = TagsViewModel(dependencies: dependencies)
    var expectedIsEmpty = false
    viewModel.onDidUpdateData = { isEmpty in
      expectedIsEmpty = isEmpty
    }
    viewModel.getTags()
    expect(expectedIsEmpty).toEventually(equal(true))
  }

  func testGettingTagsWhenNotEmpty() {
    let tags = sampleTags()
    tagService.expectedTopTags = tags
    let viewModel = TagsViewModel(dependencies: dependencies)
    var expectedIsEmpty = true
    viewModel.onDidUpdateData = { isEmpty in
      expectedIsEmpty = isEmpty
    }
    viewModel.getTags()
    expect(expectedIsEmpty).toEventually(equal(false))
  }

  func testGettingNumberOfTags() {
    let tags = sampleTags()
    tagService.expectedTopTags = tags
    let viewModel = TagsViewModel(dependencies: dependencies)
    viewModel.getTags()
    var expectedNumberOfTags = 0
    viewModel.onDidUpdateData = { [unowned viewModel] _ in
      expectedNumberOfTags = viewModel.numberOfTags
    }
    expect(expectedNumberOfTags).toEventually(equal(2))
  }

  func testGettingCellViewModel() {
    let tags = sampleTags()
    tagService.expectedTopTags = tags
    let viewModel = TagsViewModel(dependencies: dependencies)
    var expectedCellViewModel: TagCellViewModel?
    viewModel.onDidUpdateData = { [unowned viewModel] _ in
      let indexPath = IndexPath(row: 1, section: 0)
      expectedCellViewModel = viewModel.cellViewModel(at: indexPath)
    }
    viewModel.getTags()
    expect(expectedCellViewModel?.name).toEventually(equal("Tag2"))
  }

  func testSelectingTag() {
    class StubTagsViewModelDelegate: TagsViewModelDelegate {
      var selectedTagName: String = ""
      func tagsViewModel(_ viewModel: TagsViewModel, didSelectTagWithName name: String) {
        selectedTagName = name
      }
    }

    let tags = sampleTags()
    tagService.expectedTopTags = tags
    let delegate = StubTagsViewModelDelegate()
    let viewModel = TagsViewModel(dependencies: dependencies)
    viewModel.delegate = delegate
    viewModel.onDidUpdateData = { [unowned viewModel] _ in
      let indexPath = IndexPath(row: 1, section: 0)
      viewModel.selectTag(at: indexPath)
    }
    viewModel.getTags()
    expect(delegate.selectedTagName).toEventually(equal("Tag2"))
  }

  func testPerformingSearch() {
    let tags = sampleTags()
    tagService.expectedTopTags = tags
    let viewModel = TagsViewModel(dependencies: dependencies)
    var expectedNumberOfTags = 0

    var onDidGetTags: ((Bool) -> Void)?
    var onDidPerformSearch: ((Bool) -> Void)?

    onDidGetTags = { [unowned viewModel] _ in
      viewModel.onDidUpdateData = onDidPerformSearch
      viewModel.performSearch(withText: "1")
    }

    onDidPerformSearch = { [unowned viewModel] _ in
      expectedNumberOfTags = viewModel.numberOfTags
    }

    viewModel.onDidUpdateData = onDidGetTags
    viewModel.getTags()
    expect(expectedNumberOfTags).toEventually(equal(1))
  }

  func testCancellingSearch() {
    let tags = sampleTags()
    tagService.expectedTopTags = tags
    let viewModel = TagsViewModel(dependencies: dependencies)
    var expectedNumberOfTags = 0

    var onDidGetTags: ((Bool) -> Void)?
    var onDidPerformSearch: ((Bool) -> Void)?
    var onDidCancelSearch: ((Bool) -> Void)?

    onDidGetTags = { [unowned viewModel] _ in
      viewModel.onDidUpdateData = onDidPerformSearch
      viewModel.performSearch(withText: "1")
    }

    onDidPerformSearch = { [unowned viewModel] _ in
      viewModel.onDidUpdateData = onDidCancelSearch
      viewModel.cancelSearch()
    }

    onDidCancelSearch = { [unowned viewModel] _ in
      expectedNumberOfTags = viewModel.numberOfTags
    }

    viewModel.onDidUpdateData = onDidGetTags
    viewModel.getTags()

    expect(expectedNumberOfTags).toEventually(equal(2))
  }
}
