//
//  IgnoredTagsViewModel.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol IgnoredTagsViewModelDelegate: class {
  func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel)
}

class IgnoredTagsViewModel {
  typealias Dependencies = HasIgnoredTagService & HasArtistService

  private let dependencies: Dependencies
  private var ignoredTags: [IgnoredTag] {
    didSet {
      onDidUpdateTagCount?(ignoredTags.isEmpty)
    }
  }

  weak var delegate: IgnoredTagsViewModelDelegate?

  var onDidStartSavingChanges: (() -> Void)?
  var onDidFinishSavingChanges: (() -> Void)?
  var onDidAddNewTag: ((IndexPath) -> Void)?
  var onDidUpdateTagCount: ((_ isEmpty: Bool) -> Void)?
  var onDidAddDefaultTags: (() -> Void)?

  init(dependencies: Dependencies, shouldAddDefaultTags: Bool) {
    self.dependencies = dependencies
    self.ignoredTags = dependencies.ignoredTagService.ignoredTags()
    if self.ignoredTags.isEmpty && shouldAddDefaultTags {
      addDefaultTags()
    }
  }

  private func addDefaultTags() {
    dependencies.ignoredTagService.createDefaultIgnoredTags().then { [unowned self] _ -> Void in
      self.ignoredTags = self.dependencies.ignoredTagService.ignoredTags()
      self.onDidAddDefaultTags?()
    }.noError()
  }

  var numberOfIgnoredTags: Int {
    return ignoredTags.count
  }

  func cellViewModel(at indexPath: IndexPath) -> IgnoredTagCellViewModel {
    let cellViewModel = IgnoredTagCellViewModel(tag: ignoredTags[indexPath.row])
    cellViewModel.onTextChange = { [unowned self] text in
      if indexPath.row < self.ignoredTags.count {
        let ignoredTag = self.ignoredTags[indexPath.row].byUpdatingName(text.lowercased())
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
    onDidStartSavingChanges?()

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

    let calculator = ArtistTopTagsCalculator(ignoredTags: ignoredTags)
    dependencies.ignoredTagService.updateIgnoredTags(filteredTags).then { [unowned self] in
      self.dependencies.artistService.calculateTopTagsForAllArtists(using: calculator)
    }.then { [unowned self] _ -> Void in
      self.onDidFinishSavingChanges?()
      self.delegate?.ignoredTagsViewModelDidSaveChanges(self)
    }.noError()
  }
}
