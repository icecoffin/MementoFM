//
//  LibraryViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 20/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

protocol LibraryViewModelDelegate: class {
  func libraryViewModel(_ viewModel: LibraryViewModel, didSelectArtist artist: Artist)
}

class LibraryViewModel {
  private let realmGateway: RealmGateway
  private let networkService: LibraryNetworkService & UserNetworkService
  private let userDataStorage: UserDataStorage

  private(set) var isLoading = false
  fileprivate lazy var cellViewModels: RealmMappedCollection<RealmArtist, LibraryCellViewModel> = self.createCellViewModels()

  private var searchState = SearchState()

  weak var delegate: LibraryViewModelDelegate?

  var onDidStartLoading: (() -> Void)?
  var onDidFinishLoading: (() -> Void)?
  var onError: ((Error) -> Void)?

  var onSearchTextUpdate: ((String) -> Void)?

  init(realmGateway: RealmGateway,
       networkService: LibraryNetworkService & UserNetworkService = NetworkService(),
       userDataStorage: UserDataStorage = UserDataStorage()) {
    self.realmGateway = realmGateway
    self.networkService = networkService
    self.userDataStorage = userDataStorage

    cellViewModels.notificationBlock = { [unowned self] change in
      switch change {
      case .initial(_):
        break
      case .error(let error):
        self.onError?(error)
      case .update(_):
        self.onDidFinishLoading?()
      }
    }
  }

  private func createCellViewModels() -> RealmMappedCollection<RealmArtist, LibraryCellViewModel> {
    let sortDescriptor = SortDescriptor(keyPath: "playcount", ascending: false)
    return RealmMappedCollection(realm: realmGateway.defaultRealm, sort: sortDescriptor, transform: { artist -> LibraryCellViewModel in
      let viewModel = LibraryCellViewModel(artist: artist.toTransient())
      viewModel.onSelection = { [unowned self] artist in
        self.delegate?.libraryViewModel(self, didSelectArtist: artist)
      }
      return viewModel
    })
  }

  func requestData() {
    if lastUpdateTimestamp == 0 {
      getFullLibrary()
    } else {
      getLibraryUpdates()
    }
  }

  private func getFullLibrary() {
    onDidStartLoading?()
    networkService.getLibrary(for: username, progress: { progress in
      let percent = round(Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100)
      log.debug("\(percent)%")
    }).then { [unowned self] artists -> Void in
      self.updateLastUpdateTimestamp()
      let realmArtists = artists.map { RealmArtist.from(artist: $0) }
      self.realmGateway.save(objects: realmArtists) { [unowned self] in
        self.onDidFinishLoading?()
      }
    }.catch { [unowned self] error -> Void in
      self.onError?(error)
    }
  }

  private func updateLastUpdateTimestamp(date: Date = Date()) {
    userDataStorage.lastUpdateTimestamp = floor(date.timeIntervalSince1970)
  }

  private func getLibraryUpdates() {
    onDidStartLoading?()
    networkService.getRecentTracks(for: username, from: lastUpdateTimestamp) { progress in
      let percent = round(Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100)
      log.debug("\(percent)%")
    }.then { [unowned self] tracks -> Void in
      self.updateLastUpdateTimestamp()
      let processor = RecentTracksProcessor()
      processor.process(tracks: tracks, usingRealmGateway: self.realmGateway) { newArtists in
        log.debug("got \(newArtists.count) new artists")
        self.onDidFinishLoading?()
      }
    }.catch { [unowned self] error -> Void in
      self.onError?(error)
    }
  }

  private var username: String {
    return userDataStorage.username ?? ""
  }

  // TODO: returns lastUpdateTimestamp minus one day for testing purposes
  private var lastUpdateTimestamp: TimeInterval {
    let lastUpdateTimestamp = userDataStorage.lastUpdateTimestamp
    let oneDay: TimeInterval = 30 * 24 * 3600
    return lastUpdateTimestamp > oneDay ? lastUpdateTimestamp - oneDay : lastUpdateTimestamp
  }

  var title: String {
    return NSLocalizedString("Library", comment: "")
  }

  var searchBarPlaceholder: String {
    return NSLocalizedString("Search", comment: "")
  }

  var itemCount: Int {
    return cellViewModels.count
  }

  func artistViewModel(at indexPath: IndexPath) -> LibraryCellViewModel {
    return cellViewModels[indexPath.row]
  }

  func selectArtist(at indexPath: IndexPath) {
    let viewModel = cellViewModels[indexPath.row]
    viewModel.handleSelection()
  }

  // MARK: Search
  func cancelSearching() {
    searchState.currentSearch = searchState.previousSearch
    onSearchTextUpdate?(searchState.currentSearch)
  }

  func searchTextDidChange(_ searchText: String) {
    if searchText.isEmpty && searchState.hasPreviousSearch {
      finishSearching(withText: searchText)
    }
  }

  func finishSearching(withText text: String) {
    searchState.currentSearch = text
    searchState.finishCurrentSearch()

    cellViewModels.predicate = searchState.predicate
    onDidFinishLoading?()
  }
}
