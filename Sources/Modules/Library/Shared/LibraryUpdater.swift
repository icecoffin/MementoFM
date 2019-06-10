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

protocol LibraryUpdaterProtocol: class {
  var didStartLoading: (() -> Void)? { get set }
  var didFinishLoading: (() -> Void)? { get set }
  var didChangeStatus: ((LibraryUpdateStatus) -> Void)? { get set }
  var didReceiveError: ((Error) -> Void)? { get set }

  var isFirstUpdate: Bool { get }
  var lastUpdateTimestamp: TimeInterval { get }

  func requestData()
  func cancelPendingRequests()
}

final class LibraryUpdater: LibraryUpdaterProtocol {
  private let userService: UserServiceProtocol
  private let artistService: ArtistServiceProtocol
  private let tagService: TagServiceProtocol
  private let ignoredTagService: IgnoredTagServiceProtocol
  private let trackService: TrackServiceProtocol
  private let networkService: NetworkService

  private(set) var isFirstUpdate: Bool = true

  private var username: String {
    return userService.username
  }

  var lastUpdateTimestamp: TimeInterval {
    return userService.lastUpdateTimestamp
  }

  var didStartLoading: (() -> Void)?
  var didFinishLoading: (() -> Void)?
  var didChangeStatus: ((LibraryUpdateStatus) -> Void)?
  var didReceiveError: ((Error) -> Void)?

  init(userService: UserServiceProtocol, artistService: ArtistServiceProtocol, tagService: TagServiceProtocol,
       ignoredTagService: IgnoredTagServiceProtocol, trackService: TrackServiceProtocol, networkService: NetworkService) {
    self.userService = userService
    self.artistService = artistService
    self.tagService = tagService
    self.ignoredTagService = ignoredTagService
    self.trackService = trackService
    self.networkService = networkService
  }

  func requestData() {
    didStartLoading?()
    firstly {
      self.requestLibrary()
    }.then {
      self.getArtistsTags()
    }.done { _ in
      self.didFinishLoading?()
    }.catch { error in
      self.didReceiveError?(error)
    }.finally {
      self.isFirstUpdate = false
    }
  }

  func cancelPendingRequests() {
    didChangeStatus?(.artistsFirstPage)
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
    didChangeStatus?(.artistsFirstPage)
    let progress: ((Progress) -> Void) = { [weak self] progress in
      let status: LibraryUpdateStatus = .artists(progress: progress)
      self?.didChangeStatus?(status)
    }
    return artistService.getLibrary(for: username, progress: progress)
      .then { artists -> Promise<Void> in
        self.updateLastUpdateTimestamp()
        self.userService.didReceiveInitialCollection = true
        return self.artistService.saveArtists(artists)
    }
  }

  private func getLibraryUpdates() -> Promise<Void> {
    didChangeStatus?(.recentTracksFirstPage)
    let progress: ((Progress) -> Void) = { [weak self] progress in
      let status: LibraryUpdateStatus = .recentTracks(progress: progress)
      self?.didChangeStatus?(status)
    }
    return trackService.getRecentTracks(for: username, from: lastUpdateTimestamp, progress: progress)
      .then { tracks -> Promise<Void> in
        self.updateLastUpdateTimestamp()
        return self.trackService.processTracks(tracks)
    }
  }

  private func updateLastUpdateTimestamp(date: Date = Date()) {
    userService.lastUpdateTimestamp = floor(date.timeIntervalSince1970)
  }

  private func getArtistsTags() -> Promise<Void> {
    let artists = artistService.artistsNeedingTagsUpdate()
    let progress: ((TopTagsRequestProgress) -> Void) = { [weak self] requestProgress in
      guard let self = self else {
        return
      }

      let ignoredTags = self.ignoredTagService.ignoredTags()
      let calculator = ArtistTopTagsCalculator(ignoredTags: ignoredTags)

      self.artistService.updateArtist(requestProgress.artist, with: requestProgress.topTagsList.tags).then { artist in
        return self.artistService.calculateTopTags(for: artist, using: calculator)
      }.catch { error in
        self.didReceiveError?(error)
      }

      let status: LibraryUpdateStatus = .tags(artistName: requestProgress.artist.name, progress: requestProgress.progress)
      self.didChangeStatus?(status)
    }

    return tagService.getTopTags(for: artists, progress: progress)
  }
}
