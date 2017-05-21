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
  typealias Dependencies = HasRealmGateway

  private let dependencies: Dependencies
  private var cellViewModels: [TagCellViewModel] = []

  weak var delegate: TagsViewModelDelegate?

  var onDidUpdateData: (() -> Void)?

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    self.cellViewModels = []
    getTags()
  }

  func getTags() {
    dependencies.realmGateway.getAllTopTags().then { allTopTags -> Void in
      self.createCellViewModels(from: allTopTags)
    }.then(on: DispatchQueue.main) {
      self.onDidUpdateData?()
    }.noError()
  }

  var numberOfTags: Int {
    return cellViewModels.count
  }

  func cellViewModel(at indexPath: IndexPath) -> TagCellViewModel {
    return cellViewModels[indexPath.row]
  }

  func selectTag(at indexPath: IndexPath) {
    let tagName = cellViewModel(at: indexPath).name
    delegate?.tagsViewModel(self, didSelectTagWithName: tagName)
  }

  private func createCellViewModels(from tags: [Tag]) {
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
    cellViewModels = result.map { TagCellViewModel(tag: $0) }
  }
}
