//
//  SyncViewModel.swift
//  MementoFM
//
//  Created by Daniel on 30/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

// MARK: - SyncViewModelDelegate

protocol SyncViewModelDelegate: AnyObject {
    func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel)
}

// MARK: - SyncViewModel

final class SyncViewModel {
    typealias Dependencies = HasLibraryUpdater

    // MARK: - Private properties

    private let dependencies: Dependencies

    // MARK: - Public properties

    weak var delegate: SyncViewModelDelegate?

    var didChangeStatus: ((String) -> Void)?
    var didReceiveError: ((Error) -> Void)?

    // MARK: - Init

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        setup()
    }

    // MARK: - Private methods

    private func setup() {
        dependencies.libraryUpdater.didFinishLoading = { [weak self] in
            guard let self = self else {
                return
            }
            self.delegate?.syncViewModelDidFinishLoading(self)
        }

        dependencies.libraryUpdater.didChangeStatus = { [weak self] status in
            guard let self = self else {
                return
            }
            self.didChangeStatus?(self.stringFromStatus(status))
        }

        dependencies.libraryUpdater.didReceiveError = { [weak self] error in
            self?.didReceiveError?(error)
        }
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
            return ["Getting tags for",
                    artistName,
                    "(\(currentIndex) out of \(totalArtistCount))"]
                .joined(separator: "\n")
                .unlocalized
        }
    }

    // MARK: - Public methods

    func syncLibrary() {
        dependencies.libraryUpdater.cancelPendingRequests()
        dependencies.libraryUpdater.requestData()
    }
}
