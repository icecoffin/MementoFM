//
//  TagsViewModel.swift
//  LastFMNotifier
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

  // TODO: cleanup
  func getTags() {
    let ignoredTags = dependencies.realmGateway.ignoredTags().map { $0.name }
    DispatchQueue.global().async {
      let artists = self.dependencies.realmGateway.getCurrentQueueRealm().objects(RealmArtist.self)
      let allTopTags = artists.value(forKey: "topTags") as? [List<RealmTag>] ?? []
      var uniqueTagsWithCounts = [String: Int]()
      for topTags in allTopTags {
        for tag in topTags {
          let name = tag.name
          if let count = uniqueTagsWithCounts[name] {
            uniqueTagsWithCounts[name] = count + 1
          } else {
            uniqueTagsWithCounts[name] = 1
          }
        }
      }

      let result = uniqueTagsWithCounts.filter {
        !ignoredTags.contains($0.key) && $0.value > 1
      }.sorted { value1, value2 in
        value1.value > value2.value
      }.map {
        return Tag(name: $0.key, count: $0.value)
      }

      self.cellViewModels = result.map { TagCellViewModel(tag: $0) }
      DispatchQueue.main.async {
        self.onDidUpdateData?()
      }
    }
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
}
