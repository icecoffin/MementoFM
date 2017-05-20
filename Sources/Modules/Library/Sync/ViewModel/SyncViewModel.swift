//
//  SyncViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 30/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol SyncViewModelDelegate: class {
  func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel)
}

class SyncViewModel {
  typealias Dependencies = HasLibraryNetworkService & HasUserNetworkService & HasArtistNetworkService & HasRealmGateway & HasUserDataStorage

  private let dependencies: Dependencies
  private let libraryUpdater: LibraryUpdater

  weak var delegate: SyncViewModelDelegate?

  var onDidChangeStatus: ((String) -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    libraryUpdater = LibraryUpdater(dependencies: dependencies)
    setup()
  }

  private func setup() {
    libraryUpdater.onDidFinishLoading = { [unowned self] in
      self.delegate?.syncViewModelDidFinishLoading(self)
    }
    libraryUpdater.onDidChangeStatus = { [unowned self] status in
      self.onDidChangeStatus?(self.stringFromStatus(status))
    }
    libraryUpdater.onDidReceiveError = { [unowned self] error in
      self.onDidReceiveError?(error)
    }
  }

  func syncLibrary() {
    libraryUpdater.requestData()
  }

  private func stringFromStatus(_ status: LibraryUpdateStatus) -> String {
    switch status {
    case .artistsFirstPage:
      return "Updating library...".unlocalized
    case .artists(let progress):
      let currentPage = progress.completedUnitCount
      let totalPageCount = progress.totalUnitCount
      return "Updating library (page \(currentPage) out of \(totalPageCount))".unlocalized
    case .recentTracksFirstPage:
      return "Getting recent tracks...".unlocalized
    case .recentTracks(let progress):
      let currentPage = progress.completedUnitCount
      let totalPageCount = progress.totalUnitCount
      return "Getting recent tracks (page \(currentPage) out of \(totalPageCount))".unlocalized
    case .tags(let artistName, let progress):
      let currentIndex = progress.completedUnitCount
      let totalArtistCount = progress.totalUnitCount
      return "Getting tags for \(artistName) (\(currentIndex) out of \(totalArtistCount))".unlocalized
    }
  }
}
