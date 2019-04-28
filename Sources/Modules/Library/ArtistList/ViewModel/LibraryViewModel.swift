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
  typealias Dependencies = HasLibraryUpdater & HasArtistService & HasUserService

  private let dependencies: Dependencies
  private let applicationStateObserver: ApplicationStateObserving

  private lazy var artists: AnyPersistentMappedCollection<Artist> = {
    let playcountSort = NSSortDescriptor(key: "playcount", ascending: false)
    return self.dependencies.artistService.artists(sortedBy: [playcountSort])
  }()

  weak var delegate: ArtistListViewModelDelegate?

  var onDidStartLoading: (() -> Void)?
  var onDidFinishLoading: (() -> Void)?
  var onDidUpdateData: ((_ isEmpty: Bool) -> Void)?
  var onDidChangeStatus: ((String) -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  init(dependencies: Dependencies, applicationStateObserver: ApplicationStateObserving = ApplicationStateObserver()) {
    self.dependencies = dependencies
    self.applicationStateObserver = applicationStateObserver

    setup()
  }

  private func setup() {
    dependencies.libraryUpdater.onDidStartLoading = { [weak self] in
      self?.onDidStartLoading?()
    }
    dependencies.libraryUpdater.onDidFinishLoading = { [weak self] in
      guard let `self` = self else {
        return
      }
      self.onDidFinishLoading?()
      self.onDidUpdateData?(self.artists.isEmpty)
    }
    dependencies.libraryUpdater.onDidChangeStatus = { [weak self] status in
      guard let `self` = self else {
        return
      }
      self.onDidChangeStatus?(self.stringFromStatus(status))
    }
    dependencies.libraryUpdater.onDidReceiveError = { [weak self] error in
      self?.onDidReceiveError?(error)
    }

    applicationStateObserver.onApplicationDidBecomeActive = { [weak self] in
      self?.requestDataIfNeeded()
    }
  }

  func requestDataIfNeeded(currentTimestamp: TimeInterval, minTimeInterval: TimeInterval) {
    if currentTimestamp - dependencies.libraryUpdater.lastUpdateTimestamp > minTimeInterval
      || dependencies.libraryUpdater.isFirstUpdate {
      dependencies.libraryUpdater.requestData()
    }
  }

  var itemCount: Int {
    return artists.count
  }

  var title: String {
    return "Library".unlocalized
  }

  func artistViewModel(at indexPath: IndexPath) -> LibraryArtistCellViewModel {
    let artist = artists[indexPath.row]
    return LibraryArtistCellViewModel(artist: artist)
  }

  func selectArtist(at indexPath: IndexPath) {
    let artist = artists[indexPath.row]
    delegate?.artistListViewModel(self, didSelectArtist: artist)
  }

  func performSearch(withText text: String) {
    artists.predicate = text.isEmpty ? nil : NSPredicate(format: "name CONTAINS[cd] %@", text)
    self.onDidUpdateData?(artists.isEmpty)
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
