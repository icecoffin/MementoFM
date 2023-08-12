//
//  SyncViewModel.swift
//  MementoFM
//
//  Created by Daniel on 30/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import SharedServicesInterface
import Core

// MARK: - SyncViewModelDelegate

protocol SyncViewModelDelegate: AnyObject {
    func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel)
}

// MARK: - SyncViewModel

final class SyncViewModel {
    typealias Dependencies = HasLibraryUpdater

    // MARK: - Private properties

    private let dependencies: Dependencies

    private let statusSubject = PassthroughSubject<String, Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Public properties

    weak var delegate: SyncViewModelDelegate?

    var status: AnyPublisher<String, Never> {
        return statusSubject.eraseToAnyPublisher()
    }

    var error: AnyPublisher<Error, Never> {
        return errorSubject.eraseToAnyPublisher()
    }

    // MARK: - Init

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        setup()
    }

    // MARK: - Private methods

    private func setup() {
        dependencies.libraryUpdater.isLoading
            .sink(receiveValue: { [weak self] isLoading in
                guard let self = self else { return }

                if !isLoading {
                    self.delegate?.syncViewModelDidFinishLoading(self)
                }
            })
            .store(in: &cancelBag)

        dependencies.libraryUpdater.status
            .sink(receiveValue: { [weak self] status in
                guard let self = self else {
                    return
                }
                self.statusSubject.send(self.stringFromStatus(status))
            })
            .store(in: &cancelBag)

        dependencies.libraryUpdater.error
            .sink(receiveValue: { [weak self] error in
                self?.errorSubject.send(error)
            })
            .store(in: &cancelBag)
    }

    private func stringFromStatus(_ status: LibraryUpdateStatus) -> String {
        switch status {
        case .artistsFirstPage:
            return "Updating library...".unlocalized
        case .artists(let progress):
            let currentPage = progress.current
            let totalPageCount = progress.total
            return "Updating library (page \(currentPage) out of \(totalPageCount))".unlocalized
        case .recentTracksFirstPage:
            return "Getting recent tracks...".unlocalized
        case .recentTracks(let progress):
            let currentPage = progress.current
            let totalPageCount = progress.total
            return "Getting recent tracks (page \(currentPage) out of \(totalPageCount))".unlocalized
        case .tags(let artistName, let progress):
            let currentIndex = progress.current
            let totalArtistCount = progress.total
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
