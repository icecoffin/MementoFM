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
  var onDidStartLoading: (() -> Void)? { get set }
  var onDidFinishLoading: (() -> Void)? { get set }
  var onDidChangeStatus: ((LibraryUpdateStatus) -> Void)? { get set }
  var onDidReceiveError: ((Error) -> Void)? { get set }

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

  var onDidStartLoading: (() -> Void)?
  var onDidFinishLoading: (() -> Void)?
  var onDidChangeStatus: ((LibraryUpdateStatus) -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

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
    onDidStartLoading?()
    firstly {
      self.requestLibrary()
    }.then {
      self.getArtistsTags()
    }.done { _ in
      self.onDidFinishLoading?()
    }.catch { error in
      self.onDidReceiveError?(error)
    }.finally {
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
    let progress: ((Progress) -> Void) = { [weak self] progress in
      let status: LibraryUpdateStatus = .artists(progress: progress)
      self?.onDidChangeStatus?(status)
    }
    return artistService.getLibrary(for: username, progress: progress)
      .then { artists -> Promise<Void> in
        self.updateLastUpdateTimestamp()
        self.userService.didReceiveInitialCollection = true
        return self.artistService.saveArtists(artists)
    }
  }

  private func getLibraryUpdates() -> Promise<Void> {
    onDidChangeStatus?(.recentTracksFirstPage)
    let progress: ((Progress) -> Void) = { [weak self] progress in
      let status: LibraryUpdateStatus = .recentTracks(progress: progress)
      self?.onDidChangeStatus?(status)
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
        self.onDidReceiveError?(error)
      }

      let status: LibraryUpdateStatus = .tags(artistName: requestProgress.artist.name, progress: requestProgress.progress)
      self.onDidChangeStatus?(status)
    }

    return tagService.getTopTags(for: artists, progress: progress)
  }
}
