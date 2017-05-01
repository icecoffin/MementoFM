//
//  LibraryUpdater.swift
//  LastFMNotifier
//
//  Created by Daniel on 28/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

enum LibraryUpdateStatus {
  case artists(progress: Progress)
  case recentTracks(progress: Progress)
  case tags(artistName: String, progress: Progress)
}

class LibraryUpdater {
  typealias Dependencies = HasLibraryNetworkService & HasUserNetworkService & HasArtistNetworkService & HasRealmGateway & HasUserDataStorage

  private let dependencies: Dependencies

  private var username: String {
    return dependencies.userDataStorage.username
  }

  private var lastUpdateTimestamp: TimeInterval {
    return dependencies.userDataStorage.lastUpdateTimestamp
  }

  var onDidStartLoading: (() -> Void)?
  var onDidFinishLoading: (() -> Void)?
  var onDidChangeStatus: ((LibraryUpdateStatus) -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  func requestData() {
    onDidStartLoading?()
    requestLibrary().then {
      return self.getArtistsTags()
    }.then { [unowned self] _ in
      self.onDidFinishLoading?()
    }.catch { [unowned self] error in
      self.onDidReceiveError?(error)
    }
  }

  private func requestLibrary() -> Promise<Void> {
    if dependencies.userDataStorage.didReceiveInitialCollection {
      return getLibraryUpdates()
    } else {
      return getFullLibrary()
    }
  }

  private func getFullLibrary() -> Promise<Void> {
    return dependencies.libraryNetworkService.getLibrary(for: username, progress: { [weak self] progress in
      let status: LibraryUpdateStatus = .artists(progress: progress)
      self?.onDidChangeStatus?(status)
    }).then { [unowned self] artists -> Promise<Void> in
      self.updateLastUpdateTimestamp()
      let realmArtists = artists.map { RealmArtist.from(artist: $0) }
      self.dependencies.userDataStorage.didReceiveInitialCollection = true
      return self.dependencies.realmGateway.save(objects: realmArtists)
    }
  }

  private func getLibraryUpdates() -> Promise<Void> {
    return dependencies.userNetworkService.getRecentTracks(for: username, from: lastUpdateTimestamp, progress: { [weak self] progress in
      let status: LibraryUpdateStatus = .recentTracks(progress: progress)
      self?.onDidChangeStatus?(status)
    }).then { [unowned self] tracks -> Promise<Void> in
      self.updateLastUpdateTimestamp()
      let processor = RecentTracksProcessor()
      return processor.process(tracks: tracks, usingRealmGateway: self.dependencies.realmGateway).asVoid()
    }
  }

  private func updateLastUpdateTimestamp(date: Date = Date()) {
    dependencies.userDataStorage.lastUpdateTimestamp = floor(date.timeIntervalSince1970)
  }

  private func getArtistsTags() -> Promise<Void> {
    let artists = dependencies.realmGateway.artistsNeedingTagsUpdate()
    return dependencies.artistNetworkService.getTopTags(for: artists, progress: { [weak self] requestProgress in
      guard let `self` = self else {
        return
      }
      self.dependencies.realmGateway.updateArtist(requestProgress.artist, with: requestProgress.topTagsList.tags)
      let status: LibraryUpdateStatus = .tags(artistName: requestProgress.artist.name, progress: requestProgress.progress)
      self.onDidChangeStatus?(status)
    })
  }
}
