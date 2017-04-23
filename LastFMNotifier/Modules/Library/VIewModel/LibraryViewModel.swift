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
  typealias LibraryViewModelNetworkService = LibraryNetworkService & UserNetworkService & ArtistNetworkService

  private let realmGateway: RealmGateway
  private let networkService: LibraryViewModelNetworkService
  private let userDataStorage: UserDataStorage

  private(set) var isLoading = false
  fileprivate lazy var cellViewModels: RealmMappedCollection<RealmArtist, LibraryCellViewModel> = {
    return self.createCellViewModels()
  }()

  weak var delegate: LibraryViewModelDelegate?

  var onDidStartLoading: (() -> Void)?
  var onDidFinishLoading: (() -> Void)?
  var onDidUpdateData: ((_ isEmpty: Bool) -> Void)?
  var onError: ((Error) -> Void)?

  init(realmGateway: RealmGateway,
       networkService: LibraryViewModelNetworkService = NetworkService(),
       userDataStorage: UserDataStorage = UserDataStorage()) {
    self.realmGateway = realmGateway
    self.networkService = networkService
    self.userDataStorage = userDataStorage
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
    requestLibrary()
      .then {
        return self.getArtistsTags()
      }
      .then { [unowned self] _ -> Promise<Void> in
        self.onDidFinishLoading?()
        self.onDidUpdateData?(self.cellViewModels.isEmpty)
        return .void
      }
      .catch { [unowned self] error in
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
    }
  }

  private func getLibraryUpdates() -> Promise<Void> {
    onDidStartLoading?()
    return networkService.getRecentTracks(for: username, from: lastUpdateTimestamp) { progress in
      let percent = round(Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100)
      log.debug("\(percent)%")
    }.then { [unowned self] tracks -> Promise<Void> in
      self.updateLastUpdateTimestamp()
      let processor = RecentTracksProcessor()
      return processor.process(tracks: tracks, usingRealmGateway: self.realmGateway).asVoid()
    }
  }

  private func updateLastUpdateTimestamp(date: Date = Date()) {
    userDataStorage.lastUpdateTimestamp = floor(date.timeIntervalSince1970)
  }

  private func getArtistsTags() -> Promise<Void> {
    let artists = realmGateway.artistsNeedingTagsUpdate()
    return networkService.getTopTags(for: artists, progress: { requestProgress in
      self.handleTopTagsRequestProgress(requestProgress)
    })
  }

  private func handleTopTagsRequestProgress(_ requestProgress: TopTagsRequestProgress) {
    realmGateway.updateArtist(requestProgress.artist, with: requestProgress.topTagsList.tags)
    log.debug("\(requestProgress.artist.name) " +
      "(\(requestProgress.progress.completedUnitCount) out of \(requestProgress.progress.totalUnitCount))\n")
  }

  private var username: String {
    return userDataStorage.username ?? ""
  }

  // TODO: returns lastUpdateTimestamp minus one day for testing purposes
  private var lastUpdateTimestamp: TimeInterval {
    return userDataStorage.lastUpdateTimestamp
//    let lastUpdateTimestamp = userDataStorage.lastUpdateTimestamp
//    let oneDay: TimeInterval = 30 * 24 * 3600
//    return lastUpdateTimestamp > oneDay ? lastUpdateTimestamp - oneDay : lastUpdateTimestamp
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

  func finishSearching(withText text: String) {
    cellViewModels.predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
    self.onDidUpdateData?(cellViewModels.isEmpty)
  }
}
