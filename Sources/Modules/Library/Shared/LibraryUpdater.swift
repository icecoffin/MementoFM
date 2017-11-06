//
//  LibraryUpdater.swift
//  MementoFM
//
//  Created by Daniel on 28/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

enum LibraryUpdateStatus {
  case artistsFirstPage
  case artists(progress: Progress)
  case recentTracksFirstPage
  case recentTracks(progress: Progress)
  case tags(artistName: String, progress: Progress)
}

class LibraryUpdater {
  private let userService: UserService
  private let artistService: ArtistService
  private let tagService: TagService
  private let ignoredTagService: IgnoredTagService
  private let trackService: TrackService
  private let networkService: NetworkService

  private(set) var isFirstUpdate: Bool = true

  private var username: String {
    return userService.username
  }

  var lastUpdateTimestamp: TimeInterval {
    return userService.lastUpdateTimestamp
  }

  var onDidStartLoading: (() -> Void)?
  var onDidFinishLoading: (() -> Void)?
  var onDidChangeStatus: ((LibraryUpdateStatus) -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  init(userService: UserService, artistService: ArtistService, tagService: TagService, ignoredTagService: IgnoredTagService,
       trackService: TrackService, networkService: NetworkService) {
    self.userService = userService
    self.artistService = artistService
    self.tagService = tagService
    self.ignoredTagService = ignoredTagService
    self.trackService = trackService
    self.networkService = networkService
  }

  func requestData() {
    onDidStartLoading?()
    requestLibrary().then {
      return self.getArtistsTags()
    }.then { [unowned self] _ in
      self.onDidFinishLoading?()
    }.catch { [unowned self] error in
      self.onDidReceiveError?(error)
    }.always {
      self.isFirstUpdate = false
    }
  }

  func cancelPendingRequests() {
    onDidChangeStatus?(.artistsFirstPage)
    networkService.cancelPendingRequests()
  }

  private func requestLibrary() -> Promise<Void> {
    if userService.didReceiveInitialCollection {
      return getLibraryUpdates()
    } else {
      return getFullLibrary()
    }
  }

  private func getFullLibrary() -> Promise<Void> {
    onDidChangeStatus?(.artistsFirstPage)
    return artistService.getLibrary(for: username, progress: { [weak self] progress in
      let status: LibraryUpdateStatus = .artists(progress: progress)
      self?.onDidChangeStatus?(status)
    }).then { [unowned self] artists -> Promise<Void> in
      self.updateLastUpdateTimestamp()
      self.userService.didReceiveInitialCollection = true
      return self.artistService.saveArtists(artists)
    }
  }

  private func getLibraryUpdates() -> Promise<Void> {
    onDidChangeStatus?(.recentTracksFirstPage)
    return trackService.getRecentTracks(for: username, from: lastUpdateTimestamp, progress: { [weak self] progress in
      let status: LibraryUpdateStatus = .recentTracks(progress: progress)
      self?.onDidChangeStatus?(status)
    }).then { [unowned self] tracks -> Promise<Void> in
      self.updateLastUpdateTimestamp()
      return self.trackService.processTracks(tracks)
    }
  }

  private func updateLastUpdateTimestamp(date: Date = Date()) {
    userService.lastUpdateTimestamp = floor(date.timeIntervalSince1970)
  }

  private func getArtistsTags() -> Promise<Void> {
    let artists = artistService.artistsNeedingTagsUpdate()
    return tagService.getTopTags(for: artists, progress: { [weak self] requestProgress in
      guard let `self` = self else {
        return
      }
      let ignoredTags = self.ignoredTagService.ignoredTags()
      let calculator = ArtistTopTagsCalculator(ignoredTags: ignoredTags)
      self.artistService.updateArtist(requestProgress.artist,
                                                   with: requestProgress.topTagsList.tags).then { artist in
        return self.artistService.calculateTopTags(for: artist, using: calculator)
      }.noError()
      let status: LibraryUpdateStatus = .tags(artistName: requestProgress.artist.name, progress: requestProgress.progress)
      self.onDidChangeStatus?(status)
    })
  }
}
