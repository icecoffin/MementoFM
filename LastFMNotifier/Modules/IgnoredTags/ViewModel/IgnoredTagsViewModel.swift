//
//  IgnoredTagsViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol IgnoredTagsViewModelDelegate: class {
  func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel)
}

class IgnoredTagsViewModel {
  private let realmGateway: RealmGateway
  private var ignoredTags: [IgnoredTag]

  weak var delegate: IgnoredTagsViewModelDelegate?

  var onWillSaveChanges: (() -> Void)?
  var onDidAddNewTag: ((IndexPath) -> Void)?

  init(realmGateway: RealmGateway) {
    self.realmGateway = realmGateway
    self.ignoredTags = realmGateway.ignoredTags()
  }

  var title: String {
    return NSLocalizedString("Ignored Tags", comment: "")
  }

  var numberOfIgnoredTags: Int {
    return ignoredTags.count
  }

  func cellViewModel(at indexPath: IndexPath) -> IgnoredTagCellViewModel {
    let cellViewModel = IgnoredTagCellViewModel(tag: ignoredTags[indexPath.row])
    cellViewModel.onTextChange = { [unowned self] text in
      if indexPath.row < self.ignoredTags.count {
        let ignoredTag = self.ignoredTags[indexPath.row].updateName(text)
        self.ignoredTags[indexPath.row] = ignoredTag
      }
    }
    return cellViewModel
  }

  func addNewIgnoredTag() {
    let newTag = IgnoredTag(uuid: UUID().uuidString, name: "")
    ignoredTags.append(newTag)
    let newTagIndexPath = IndexPath(item: ignoredTags.count - 1, section: 0)
    onDidAddNewTag?(newTagIndexPath)
  }

  func deleteIgnoredTag(at indexPath: IndexPath) {
    ignoredTags.remove(at: indexPath.row)
  }

  func saveChanges() {
    onWillSaveChanges?()

    let filteredTags = ignoredTags.reduce([]) { result, ignoredTag -> [IgnoredTag] in
      if ignoredTag.name.isEmpty {
        return result
      }
      let isDuplicate = result.contains(where: { tag -> Bool in
        return ignoredTag.name == tag.name
      })
      if isDuplicate {
        return result
      }
      return result + [ignoredTag]
    }

    print(filteredTags.map({ $0.name }))
    _ = realmGateway.updateIgnoredTags(filteredTags).then { [unowned self] in
      self.delegate?.ignoredTagsViewModelDidSaveChanges(self)
    }
  }
}
