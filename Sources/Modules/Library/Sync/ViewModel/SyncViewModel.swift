//
//  SyncViewModel.swift
//  MementoFM
//
//  Created by Daniel on 30/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol SyncViewModelDelegate: class {
  func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel)
}

class SyncViewModel {
  typealias Dependencies = HasLibraryUpdater

  private let dependencies: Dependencies

  weak var delegate: SyncViewModelDelegate?

  var onDidChangeStatus: ((String) -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    setup()
  }

  private func setup() {
    dependencies.libraryUpdater.onDidFinishLoading = { [weak self] in
      guard let `self` = self else {
        return
      }
      self.delegate?.syncViewModelDidFinishLoading(self)
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
  }

  func syncLibrary() {
    dependencies.libraryUpdater.cancelPendingRequests()
    dependencies.libraryUpdater.requestData()
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
      return ["Getting tags for", artistName, "(\(currentIndex) out of \(totalArtistCount))"].joined(separator: "\n").unlocalized
    }
  }
}
