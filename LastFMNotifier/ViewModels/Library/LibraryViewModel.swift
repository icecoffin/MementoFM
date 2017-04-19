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

class LibraryViewModel {
  private let realmGateway: RealmGateway
  private let networkService: LibraryNetworkService & UserNetworkService
  private let userDataStorage: UserDataStorage

  private(set) var isLoading = false
  fileprivate lazy var cellViewModels: RealmMappedCollection<RealmArtist, LibraryCellViewModel> = {
    return self.createCellViewModels()
  }()

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
  }

  deinit {
    print("deinit LibraryViewModel")
  }

  private func createCellViewModels() -> RealmMappedCollection<RealmArtist, LibraryCellViewModel> {
    let playcountSort = SortDescriptor(keyPath: "playcount", ascending: false)
    return RealmMappedCollection(realm: realmGateway.defaultRealm,
                                 sortDescriptors: [playcountSort],
                                 transform: { [unowned self] artist -> LibraryCellViewModel in
      let viewModel = LibraryCellViewModel(artist: artist.toTransient())
      viewModel.onSelection = { artist in
        self.delegate?.libraryViewModel(self, didSelectArtist: artist)
      }
      return viewModel
    })
  }

  func requestData() {
    requestLibrary().catch { [unowned self] error in
      self.onError?(error)
    }
  }

  func requestLibrary() -> Promise<Void> {
    if userDataStorage.didReceiveInitialCollection {
      return getLibraryUpdates()
    } else {
      return getFullLibrary()
    }
  }

  private func getFullLibrary() -> Promise<Void> {
    onDidStartLoading?()
    return networkService.getLibrary(for: username, progress: { progress in
      let percent = round(Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100)
      log.debug("\(percent)%")
    }).then { [unowned self] artists -> Promise<Void> in
      self.updateLastUpdateTimestamp()
      let realmArtists = artists.map { RealmArtist.from(artist: $0) }
      self.userDataStorage.didReceiveInitialCollection = true
      return self.realmGateway.save(objects: realmArtists)
    }.then { [unowned self] _ in
      self.onDidFinishLoading?()
    }
  }

  private func getLibraryUpdates() -> Promise<Void> {
    onDidStartLoading?()
    return networkService.getRecentTracks(for: username, from: lastUpdateTimestamp) { progress in
      let percent = round(Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100)
      log.debug("\(percent)%")
    }.then { [unowned self] tracks -> Void in
      self.updateLastUpdateTimestamp()
      let processor = RecentTracksProcessor()
      processor.process(tracks: tracks, usingRealmGateway: self.realmGateway) { [unowned self] newArtists in
        log.debug("got \(newArtists.count) new artists")
        self.onDidFinishLoading?()
      }
    }
  }

  private func updateLastUpdateTimestamp(date: Date = Date()) {
    userDataStorage.lastUpdateTimestamp = floor(date.timeIntervalSince1970)
  }

  private func getArtistsTags() {

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

  // TODO: empty data set view
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
