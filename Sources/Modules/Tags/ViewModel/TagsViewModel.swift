//
//  TagsViewModel.swift
//  MementoFM
//
//  Created by Daniel on 16/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

protocol TagsViewModelDelegate: class {
  func tagsViewModel(_ viewModel: TagsViewModel, didSelectTagWithName name: String)
}

class TagsViewModel {
  typealias Dependencies = HasTagService

  private let dependencies: Dependencies
  private var allCellViewModels: [TagCellViewModel] = []
  private var filteredCellViewModels: [TagCellViewModel] = []

  weak var delegate: TagsViewModelDelegate?

  var onDidUpdateData: ((_ isEmpty: Bool) -> Void)?

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    getTags()
  }

  func getTags(searchText: String? = nil) {
    dependencies.tagService.getAllTopTags().then { allTopTags -> Void in
      self.createCellViewModels(from: allTopTags, searchText: searchText)
    }.then(on: DispatchQueue.main) {
      self.onDidUpdateData?(self.filteredCellViewModels.isEmpty)
    }.noError()
  }

  var numberOfTags: Int {
    return filteredCellViewModels.count
  }

  func cellViewModel(at indexPath: IndexPath) -> TagCellViewModel {
    return filteredCellViewModels[indexPath.row]
  }

  func selectTag(at indexPath: IndexPath) {
    let tagName = cellViewModel(at: indexPath).name
    delegate?.tagsViewModel(self, didSelectTagWithName: tagName)
  }

  private func createCellViewModels(from tags: [Tag], searchText: String?) {
    var uniqueTagNamesWithCounts = [String: Int]()
    for tag in tags {
      let name = tag.name
      if let count = uniqueTagNamesWithCounts[name] {
        uniqueTagNamesWithCounts[name] = count + 1
      } else {
        uniqueTagNamesWithCounts[name] = 1
      }
    }

    let result = uniqueTagNamesWithCounts.filter {
      $0.value > 1
    }.sorted { value1, value2 in
      value1.value > value2.value
    }.map {
      return Tag(name: $0.key, count: $0.value)
    }
    allCellViewModels = result.map { TagCellViewModel(tag: $0) }
    createFilteredCellViewModels(filter: searchText)
  }

  private func createFilteredCellViewModels(filter text: String?) {
    if let text = text, !text.isEmpty {
      filteredCellViewModels = allCellViewModels.filter({ $0.name.range(of: text, options: .caseInsensitive) != nil })
    } else {
      filteredCellViewModels = allCellViewModels
    }
  }

  func performSearch(withText text: String?) {
    createFilteredCellViewModels(filter: text)
    onDidUpdateData?(filteredCellViewModels.isEmpty)
  }

  func cancelSearch() {
    performSearch(withText: nil)
  }
}
