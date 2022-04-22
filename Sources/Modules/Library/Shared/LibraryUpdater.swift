//
//  LibraryUpdater.swift
//  MementoFM
//
//  Created by Daniel on 28/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - LibraryUpdateStatus

enum LibraryUpdateStatus {
    case artistsFirstPage
    case artists(progress: PageProgress)
    case recentTracksFirstPage
    case recentTracks(progress: PageProgress)
    case tags(artistName: String, progress: PageProgress)
}

// MARK: - LibraryUpdaterProtocol

protocol LibraryUpdaterProtocol: AnyObject {
    var isLoading: AnyPublisher<Bool, Never> { get }
    var status: AnyPublisher<LibraryUpdateStatus, Never> { get }
    var error: AnyPublisher<Error, Never> { get }

    var isFirstUpdate: Bool { get }
    var lastUpdateTimestamp: TimeInterval { get }

    func requestData()
    func cancelPendingRequests()
}

// MARK: - LibraryUpdater

final class LibraryUpdater: LibraryUpdaterProtocol {
    // MARK: - Private properties

    private let userService: UserServiceProtocol
    private let artistService: ArtistServiceProtocol
    private let tagService: TagServiceProtocol
    private let ignoredTagService: IgnoredTagServiceProtocol
    private let trackService: TrackServiceProtocol
    private let countryService: CountryServiceProtocol
    private let networkService: NetworkService

    private var username: String {
        return userService.username
    }

    private var isLoadingSubject = PassthroughSubject<Bool, Never>()
    private var statusSubject = PassthroughSubject<LibraryUpdateStatus, Never>()
    private var errorSubject = PassthroughSubject<Error, Never>()
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Public methods

    private(set) var isFirstUpdate: Bool = true

    var isLoading: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }

    var status: AnyPublisher<LibraryUpdateStatus, Never> {
        return statusSubject.eraseToAnyPublisher()
    }

    var error: AnyPublisher<Error, Never> {
        return errorSubject.eraseToAnyPublisher()
    }

    var lastUpdateTimestamp: TimeInterval {
        return userService.lastUpdateTimestamp
    }

    // MARK: - Init

    init(userService: UserServiceProtocol,
         artistService: ArtistServiceProtocol,
         tagService: TagServiceProtocol,
         ignoredTagService: IgnoredTagServiceProtocol,
         trackService: TrackServiceProtocol,
         countryService: CountryServiceProtocol,
         networkService: NetworkService) {
        self.userService = userService
        self.artistService = artistService
        self.tagService = tagService
        self.ignoredTagService = ignoredTagService
        self.trackService = trackService
        self.countryService = countryService
        self.networkService = networkService
    }

    // MARK: - Private methods

    private func requestLibrary() -> AnyPublisher<Void, Error> {
        if userService.didReceiveInitialCollection {
            return getLibraryUpdates()
        } else {
            return getFullLibrary()
        }
    }

    private func getFullLibrary() -> AnyPublisher<Void, Error> {
        statusSubject.send(.artistsFirstPage)

        let getLibrary = artistService
            .getLibrary(for: username)

        // TODO: remove side effect
        getLibrary
            .dropFirst()
            .scan(PageProgress(current: 1, total: 0), { progress, libraryPage in
                var newProgress = progress
                newProgress.current += 1
                newProgress.total = libraryPage.totalPages
                return newProgress
            })
            .sink { _ in
            } receiveValue: { [weak self] pageProgress in
                self?.statusSubject.send(.artists(progress: pageProgress))
            }
            .store(in: &cancelBag)

        return getLibrary
            .collect()
            .flatMap { [weak self] pages -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Empty()
                        .eraseToAnyPublisher()
                }

                let artists = pages.map { $0.artists }.flatMap { $0 }
                self.updateLastUpdateTimestamp()
                self.userService.didReceiveInitialCollection = true
                return self.artistService.saveArtists(artists)
            }
            .eraseToAnyPublisher()
    }

    private func getLibraryUpdates() -> AnyPublisher<Void, Error> {
        statusSubject.send(.recentTracksFirstPage)
        let getRecentTracks = trackService
            .getRecentTracks(for: username, from: lastUpdateTimestamp)

        getRecentTracks
            .dropFirst()
            .scan(PageProgress(current: 1, total: 0), { progress, recentTracksPage in
                var newProgress = progress
                newProgress.current += 1
                newProgress.total = recentTracksPage.totalPages
                return newProgress
            })
            .sink { _ in
            } receiveValue: { [weak self] pageProgress in
                self?.statusSubject.send(.recentTracks(progress: pageProgress))
            }
            .store(in: &cancelBag)

        return getRecentTracks
            .collect()
            .flatMap { [weak self] pages -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Empty()
                        .eraseToAnyPublisher()
                }

                let tracks = pages.map { $0.tracks }.flatMap { $0 }
                self.updateLastUpdateTimestamp()
                return self.trackService.processTracks(tracks)
            }
            .eraseToAnyPublisher()
    }

    private func updateLastUpdateTimestamp(date: Date = Date()) {
        userService.lastUpdateTimestamp = floor(date.timeIntervalSince1970)
    }

    private func getArtistsTags() -> AnyPublisher<Void, Error> {
        let artists = artistService.artistsNeedingTagsUpdate()
        let getArtistsTags = tagService
            .getTopTags(for: artists)

        let pages = getArtistsTags
            .dropFirst()
            .scan(PageProgress(current: 1, total: artists.count)) { progress, _ in
                var newProgress = progress
                newProgress.current += 1
                return newProgress
            }
        let artistNames = Publishers.Sequence(sequence: artists.map { $0.name })
            .setFailureType(to: Error.self)

        // TODO: remove side effect
        Publishers.Zip(pages, artistNames)
            .sink { _ in
            } receiveValue: { [weak self] (pageProgress, artistName) in
                self?.statusSubject.send(.tags(artistName: artistName, progress: pageProgress))
            }
            .store(in: &cancelBag)

        let ignoredTags = self.ignoredTagService.ignoredTags()
        let calculator = ArtistTopTagsCalculator(ignoredTags: ignoredTags)

        return getArtistsTags
            .flatMap { topTagsPage in
                self.artistService.updateArtist(topTagsPage.artist,
                                                with: topTagsPage.topTagsList.tags)
            }
            .flatMap { artist in
                return self.artistService.calculateTopTags(for: artist, using: calculator)
            }
            .collect()
            .map { _ in }
            .eraseToAnyPublisher()
    }

    // MARK: - Public methods

    func requestData() {
        isLoadingSubject.send(true)

        requestLibrary()
            .flatMap { _ -> AnyPublisher<Void, Error> in
                return self.getArtistsTags()
            }
            .flatMap { _ -> AnyPublisher<Void, Error> in
                return self.countryService.updateCountries()
            }
            .sink { [weak self] completion in
                self?.isFirstUpdate = false
                self?.isLoadingSubject.send(false)
                if case .failure(let error) = completion {
                    self?.errorSubject.send(error)
                }
            } receiveValue: { _ in }
            .store(in: &cancelBag)
    }

    func cancelPendingRequests() {
        statusSubject.send(.artistsFirstPage)
        // TODO: implement cancelling publishers
        cancelBag.forEach { $0.cancel() }
    }
}
