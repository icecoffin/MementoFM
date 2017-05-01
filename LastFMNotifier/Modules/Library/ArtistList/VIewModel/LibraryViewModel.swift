//
//  LibraryViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 20/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit

protocol LibraryViewModelDelegate: class {
  func libraryViewModel(_ viewModel: LibraryViewModel, didSelectArtist artist: Artist)
}

// TODO: check why photos are not displayed when opening after onboarding
class LibraryViewModel {
  typealias Dependencies = HasLibraryNetworkService & HasUserNetworkService & HasArtistNetworkService & HasRealmGateway & HasUserDataStorage

  private let dependencies: Dependencies
  private let libraryUpdater: LibraryUpdater

  fileprivate lazy var cellViewModels: RealmMappedCollection<RealmArtist, LibraryArtistCellViewModel> = {
    return self.createCellViewModels()
  }()

  weak var delegate: LibraryViewModelDelegate?

  var onDidStartLoading: (() -> Void)?
  var onDidFinishLoading: (() -> Void)?
  var onDidUpdateData: ((_ isEmpty: Bool) -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    libraryUpdater = LibraryUpdater(dependencies: dependencies)

    setup()
  }

  private func createCellViewModels() -> RealmMappedCollection<RealmArtist, LibraryArtistCellViewModel> {
    let playcountSort = SortDescriptor(keyPath: "playcount", ascending: false)
    return RealmMappedCollection(realm: dependencies.realmGateway.defaultRealm,
                                 sortDescriptors: [playcountSort],
                                 transform: { [unowned self] artist -> LibraryArtistCellViewModel in
      let viewModel = LibraryArtistCellViewModel(artist: artist.toTransient())
      viewModel.onSelection = { artist in
        self.delegate?.libraryViewModel(self, didSelectArtist: artist)
      }
      return viewModel
    })
  }

  private func setup() {
    libraryUpdater.onDidStartLoading = { [unowned self] in
      self.onDidStartLoading?()
    }
    libraryUpdater.onDidFinishLoading = { [unowned self] in
      self.onDidFinishLoading?()
      self.onDidUpdateData?(self.cellViewModels.isEmpty)
    }
    // TODO: better progress display
    libraryUpdater.onDidChangeStatus = { /*[unowned self]*/ status in
      log.debug(status)
    }
    libraryUpdater.onDidReceiveError = { [unowned self] error in
      self.onDidReceiveError?(error)
    }
  }

  func requestData() {
    libraryUpdater.requestData()
  }

  private var username: String {
    return dependencies.userDataStorage.username
  }

  private var lastUpdateTimestamp: TimeInterval {
    return dependencies.userDataStorage.lastUpdateTimestamp
  }

  var searchBarPlaceholder: String {
    return "Search".unlocalized
  }

  var itemCount: Int {
    return cellViewModels.count
  }

  func artistViewModel(at indexPath: IndexPath) -> LibraryArtistCellViewModel {
    return cellViewModels[indexPath.row]
  }

  func selectArtist(at indexPath: IndexPath) {
    let viewModel = cellViewModels[indexPath.row]
    viewModel.handleSelection()
  }

  func finishSearching(withText text: String) {
    cellViewModels.predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
    self.onDidUpdateData?(cellViewModels.isEmpty)
  }
}
