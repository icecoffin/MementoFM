//
//  LibraryViewModel.swift
//  MementoFM
//
//  Created by Daniel on 20/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit

class LibraryViewModel: ArtistListViewModel {
  typealias Dependencies = HasLibraryNetworkService & HasUserNetworkService & HasArtistNetworkService & HasRealmGateway & HasUserDataStorage

  private let dependencies: Dependencies
  private let applicationStateObserver: ApplicationStateObserver
  private let libraryUpdater: LibraryUpdater

  fileprivate lazy var cellViewModels: RealmMappedCollection<RealmArtist, LibraryArtistCellViewModel> = {
    return self.createCellViewModels()
  }()

  weak var delegate: ArtistListViewModelDelegate?

  var onDidStartLoading: (() -> Void)?
  var onDidFinishLoading: (() -> Void)?
  var onDidUpdateData: ((_ isEmpty: Bool) -> Void)?
  var onDidChangeStatus: ((String) -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  init(dependencies: Dependencies, applicationStateObserver: ApplicationStateObserver = .init()) {
    self.dependencies = dependencies
    self.applicationStateObserver = applicationStateObserver
    libraryUpdater = LibraryUpdater(dependencies: dependencies)

    setup()
  }

  private func createCellViewModels() -> RealmMappedCollection<RealmArtist, LibraryArtistCellViewModel> {
    let playcountSort = SortDescriptor(keyPath: "playcount", ascending: false)
    return RealmMappedCollection(realm: dependencies.realmGateway.mainQueueRealm,
                                 sortDescriptors: [playcountSort],
                                 transform: { [unowned self] artist -> LibraryArtistCellViewModel in
      let viewModel = LibraryArtistCellViewModel(artist: artist.toTransient())
      viewModel.onSelection = { artist in
        self.delegate?.artistListViewModel(self, didSelectArtist: artist)
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
    libraryUpdater.onDidChangeStatus = { [unowned self] status in
      self.onDidChangeStatus?(self.stringFromStatus(status))
    }
    libraryUpdater.onDidReceiveError = { [unowned self] error in
      self.onDidReceiveError?(error)
    }

    applicationStateObserver.onApplicationDidBecomeActive = { [weak self] in
      self?.requestDataIfNeeded()
    }
  }

  func requestDataIfNeeded(currentTimestamp: TimeInterval = Date().timeIntervalSince1970) {
    if currentTimestamp - lastUpdateTimestamp > 30 {
      libraryUpdater.requestData()
    }
  }

  private var lastUpdateTimestamp: TimeInterval {
    return dependencies.userDataStorage.lastUpdateTimestamp
  }

  var itemCount: Int {
    return cellViewModels.count
  }

  var title: String {
    return "Library".unlocalized
  }

  func artistViewModel(at indexPath: IndexPath) -> LibraryArtistCellViewModel {
    return cellViewModels[indexPath.row]
  }

  func selectArtist(at indexPath: IndexPath) {
    let viewModel = cellViewModels[indexPath.row]
    viewModel.handleSelection()
  }

  func performSearch(withText text: String) {
    cellViewModels.predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
    self.onDidUpdateData?(cellViewModels.isEmpty)
  }

  private func stringFromStatus(_ status: LibraryUpdateStatus) -> String {
    switch status {
    case .artistsFirstPage:
      return "Getting library...".unlocalized
    case .artists(let progress):
      return "Getting library: page \(progress.completedUnitCount) out of \(progress.totalUnitCount)".unlocalized
    case .recentTracksFirstPage:
      return "Getting recent tracks..."
    case .recentTracks(let progress):
      return "Getting recent tracks: page \(progress.completedUnitCount) out of \(progress.totalUnitCount)".unlocalized
    case .tags(_, let progress):
      return "Getting tags for artists: \(progress.completedUnitCount) out of \(progress.totalUnitCount)".unlocalized
    }
  }
}
