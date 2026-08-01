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

    func requestData() async
    func resetStatus()
}

// MARK: - LibraryUpdater

final class LibraryUpdater: LibraryUpdaterProtocol {
    // MARK: - Private properties

    private let userService: UserServiceProtocol
    private let artistService: ArtistServiceProtocol
    private let tagService: TagServiceProtocol
    private let ignoredTagService: IgnoredTagServiceProtocol
    private let trackService: TrackServiceProtocol
    private let recentTracksProcessor: RecentTracksProcessing
    private let countryService: CountryServiceProtocol

    private var username: String {
        return userService.username
    }

    private var isLoadingSubject = PassthroughSubject<Bool, Never>()
    private var statusSubject = PassthroughSubject<LibraryUpdateStatus, Never>()
    private var errorSubject = PassthroughSubject<Error, Never>()

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

    init(
        userService: UserServiceProtocol,
        artistService: ArtistServiceProtocol,
        tagService: TagServiceProtocol,
        ignoredTagService: IgnoredTagServiceProtocol,
        trackService: TrackServiceProtocol,
        recentTracksProcessor: RecentTracksProcessing,
        countryService: CountryServiceProtocol
    ) {
        self.userService = userService
        self.artistService = artistService
        self.tagService = tagService
        self.ignoredTagService = ignoredTagService
        self.trackService = trackService
        self.recentTracksProcessor = recentTracksProcessor
        self.countryService = countryService
    }

    // MARK: - Private methods

    private func requestLibrary() async throws {
        if userService.didReceiveInitialCollection {
            try await getLibraryUpdates()
        } else {
            try await getFullLibrary()
        }
    }

    private func getFullLibrary() async throws {
        statusSubject.send(.artistsFirstPage)

        var pages: [LibraryPage] = []

        for try await libraryPage in artistService.getLibrary(for: username) {
            pages.append(libraryPage)

            if pages.count > 1 {
                statusSubject.send(
                    .artists(
                        progress: PageProgress(
                            current: pages.count,
                            total: libraryPage.totalPages
                        )
                    )
                )
            }
        }

        let artists = pages.map { $0.artists }.flatMap { $0 }
        updateLastUpdateTimestamp()
        userService.didReceiveInitialCollection = true
        try await artistService.saveArtists(artists)
    }

    private func getLibraryUpdates() async throws {
        statusSubject.send(.recentTracksFirstPage)

        var pages: [RecentTracksPage] = []

        for try await recentTracksPage in trackService.getRecentTracks(
            for: username,
            from: lastUpdateTimestamp
        ) {
            pages.append(recentTracksPage)

            if pages.count > 1 {
                statusSubject.send(
                    .recentTracks(
                        progress: PageProgress(
                            current: pages.count,
                            total: recentTracksPage.totalPages
                        )
                    )
                )
            }
        }

        let tracks = pages.map { $0.tracks }.flatMap { $0 }
        updateLastUpdateTimestamp()
        try await recentTracksProcessor.process(tracks: tracks)
    }

    private func updateLastUpdateTimestamp(date: Date = Date()) {
        userService.lastUpdateTimestamp = floor(date.timeIntervalSince1970)
    }

    private func getArtistsTags() async throws {
        let artists = artistService.artistsNeedingTagsUpdate()
        let ignoredTags = ignoredTagService.ignoredTags()
        let calculator = ArtistTopTagsCalculator(ignoredTags: ignoredTags)

        var pageIndex = 0
        for try await topTagsPage in tagService.getTopTags(for: artists) {
            if pageIndex > 0 {
                statusSubject.send(
                    .tags(
                        artistName: topTagsPage.artist.name,
                        progress: PageProgress(
                            current: pageIndex,
                            total: artists.count
                        )
                    )
                )
            }
            pageIndex += 1
            let updatedArtist = try await artistService.updateArtist(
                topTagsPage.artist,
                with: topTagsPage.topTagsList.tags
            )
            try await artistService.calculateTopTags(for: updatedArtist, using: calculator)
        }
    }

    private func runUpdate() async {

    }

    // MARK: - Public methods

    func requestData() async {
        isLoadingSubject.send(true)
        defer { isLoadingSubject.send(false) }

        do {
            try await requestLibrary()
            try await getArtistsTags()
            try await countryService.updateCountries()

            isFirstUpdate = false
        } catch is CancellationError {
            return
        } catch {
            errorSubject.send(error)
        }
    }

    func resetStatus() {
        statusSubject.send(.artistsFirstPage)
    }
}
