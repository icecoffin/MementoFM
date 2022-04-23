//
//  LibraryViewModel.swift
//  MementoFM
//
//  Created by Daniel on 20/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

final class LibraryViewModel: ArtistListViewModel {
    typealias Dependencies = HasLibraryUpdater & HasArtistService & HasUserService

    // MARK: - Private properties

    private let dependencies: Dependencies
    private let applicationStateObserver: ApplicationStateObserving

    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let didUpdateSubject = PassthroughSubject<Result<Bool, Error>, Never>()
    private let statusSubject = PassthroughSubject<String, Never>()

    private var cancelBag = Set<AnyCancellable>()

    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()

    private lazy var artists: AnyPersistentMappedCollection<Artist> = {
        let playcountSort = NSSortDescriptor(key: "playcount", ascending: false)
        return self.dependencies.artistService.artists(sortedBy: [playcountSort])
    }()

    // MARK: - Public properties

    weak var delegate: ArtistListViewModelDelegate?

    var isLoading: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }

    var didUpdate: AnyPublisher<Result<Bool, Error>, Never> {
        return didUpdateSubject.eraseToAnyPublisher()
    }

    var status: AnyPublisher<String, Never> {
        return statusSubject.eraseToAnyPublisher()
    }

    var itemCount: Int {
        return artists.count
    }

    var title: String {
        return "Library".unlocalized
    }

    // MARK: - Init

    init(dependencies: Dependencies, applicationStateObserver: ApplicationStateObserving = ApplicationStateObserver()) {
        self.dependencies = dependencies
        self.applicationStateObserver = applicationStateObserver

        setup()
    }

    // MARK: - Private methods

    private func setup() {
        dependencies.libraryUpdater.isLoading
            .sink(receiveValue: { [weak self] isLoading in
                guard let self = self else { return }

                self.isLoadingSubject.send(isLoading)
                if !isLoading {
                    self.didUpdateSubject.send(.success(self.artists.isEmpty))
                }
            })
            .store(in: &cancelBag)

        dependencies.libraryUpdater.status
            .sink(receiveValue: { [weak self] status in
                guard let self = self else { return }

                self.statusSubject.send(self.stringFromStatus(status))
            })
            .store(in: &cancelBag)

        dependencies.libraryUpdater.error
            .sink(receiveValue: { [weak self] error in
                self?.didUpdateSubject.send(.failure(error))
            })
            .store(in: &cancelBag)

        applicationStateObserver.applicationDidBecomeActive
            .sink { [weak self] _ in
                self?.requestDataIfNeeded()
            }
            .store(in: &cancelBag)
    }

    private func stringFromStatus(_ status: LibraryUpdateStatus) -> String {
        switch status {
        case .artistsFirstPage:
            return "Getting library...".unlocalized
        case .artists(let progress):
            return "Getting library: page \(progress.current) out of \(progress.total)".unlocalized
        case .recentTracksFirstPage:
            return "Getting recent tracks..."
        case .recentTracks(let progress):
            return "Getting recent tracks: page \(progress.current) out of \(progress.total)".unlocalized
        case .tags(_, let progress):
            return "Getting tags for artists: \(progress.current) out of \(progress.total)".unlocalized
        }
    }

    // MARK: - Public methods

    func requestDataIfNeeded(currentTimestamp: TimeInterval, minTimeInterval: TimeInterval) {
        if currentTimestamp - dependencies.libraryUpdater.lastUpdateTimestamp > minTimeInterval
            || dependencies.libraryUpdater.isFirstUpdate {
            dependencies.libraryUpdater.requestData()
        }
    }

    func artistViewModel(at indexPath: IndexPath) -> LibraryArtistCellViewModel {
        let artist = artists[indexPath.row]
        return LibraryArtistCellViewModel(artist: artist,
                                          index: indexPath.row + 1,
                                          numberFormatter: numberFormatter)
    }

    func selectArtist(at indexPath: IndexPath) {
        let artist = artists[indexPath.row]
        delegate?.artistListViewModel(self, didSelectArtist: artist)
    }

    func performSearch(withText text: String) {
        artists.predicate = text.isEmpty ? nil : NSPredicate(format: "name CONTAINS[cd] %@", text)
        self.didUpdateSubject.send(.success(artists.isEmpty))
    }
}
