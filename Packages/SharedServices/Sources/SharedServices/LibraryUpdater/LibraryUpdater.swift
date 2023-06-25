import Foundation
import Combine
import TransientModels
import SharedServicesInterface

public final class LibraryUpdater: LibraryUpdaterProtocol {
    // MARK: - Private properties

    private let userService: UserServiceProtocol
    private let artistService: ArtistServiceProtocol
    private let tagService: TagServiceProtocol
    private let ignoredTagService: IgnoredTagServiceProtocol
    private let trackService: TrackServiceProtocol
    private let countryService: CountryServiceProtocol

    private var username: String {
        return userService.username
    }

    private var isLoadingSubject = PassthroughSubject<Bool, Never>()
    private var statusSubject = PassthroughSubject<LibraryUpdateStatus, Never>()
    private var errorSubject = PassthroughSubject<Error, Never>()
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Public methods

    private(set) public var isFirstUpdate: Bool = true

    public var isLoading: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }

    public var status: AnyPublisher<LibraryUpdateStatus, Never> {
        return statusSubject.eraseToAnyPublisher()
    }

    public var error: AnyPublisher<Error, Never> {
        return errorSubject.eraseToAnyPublisher()
    }

    public var lastUpdateTimestamp: TimeInterval {
        return userService.lastUpdateTimestamp
    }

    // MARK: - Init

    public init(
        userService: UserServiceProtocol,
        artistService: ArtistServiceProtocol,
        tagService: TagServiceProtocol,
        ignoredTagService: IgnoredTagServiceProtocol,
        trackService: TrackServiceProtocol,
        countryService: CountryServiceProtocol
    ) {
        self.userService = userService
        self.artistService = artistService
        self.tagService = tagService
        self.ignoredTagService = ignoredTagService
        self.trackService = trackService
        self.countryService = countryService
    }

    // MARK: - Private methods

    private func requestLibrary() -> (progress: AnyPublisher<LibraryUpdateStatus, Error>,
                                      result: AnyPublisher<Void, Error>) {
        if userService.didReceiveInitialCollection {
            return getLibraryUpdates()
        } else {
            return getFullLibrary()
        }
    }

    private func getFullLibrary() -> (progress: AnyPublisher<LibraryUpdateStatus, Error>,
                                      result: AnyPublisher<Void, Error>) {
        statusSubject.send(.artistsFirstPage)

        let getLibrary = artistService
            .getLibrary(for: username)

        let progress = getLibrary
            .dropFirst()
            .scan(PageProgress(current: 1, total: 0), { progress, libraryPage in
                var newProgress = progress
                newProgress.current += 1
                newProgress.total = libraryPage.totalPages
                return newProgress
            })
            .map { pageProgress -> LibraryUpdateStatus in
                return .artists(progress: pageProgress)
            }
            .eraseToAnyPublisher()

        let result = getLibrary
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

        return (progress, result)
    }

    private func getLibraryUpdates() -> (progress: AnyPublisher<LibraryUpdateStatus, Error>,
                                         result: AnyPublisher<Void, Error>) {
        statusSubject.send(.recentTracksFirstPage)
        let getRecentTracks = trackService
            .getRecentTracks(for: username, from: lastUpdateTimestamp)

        let progress = getRecentTracks
            .dropFirst()
            .scan(PageProgress(current: 1, total: 0), { progress, recentTracksPage in
                var newProgress = progress
                newProgress.current += 1
                newProgress.total = recentTracksPage.totalPages
                return newProgress
            })
            .map { pageProgress -> LibraryUpdateStatus in
                return .recentTracks(progress: pageProgress)
            }
            .eraseToAnyPublisher()

        let result = getRecentTracks
            .collect()
            .flatMap { [weak self] pages -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Empty()
                        .eraseToAnyPublisher()
                }

                let tracks = pages.map { $0.tracks }.flatMap { $0 }
                self.updateLastUpdateTimestamp()
                // TODO: DI
                return self.trackService.processTracks(tracks, using: RecentTracksProcessor())
            }
            .eraseToAnyPublisher()

        return (progress, result)
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

        Publishers.Zip(pages, artistNames)
            .sink { _ in
            } receiveValue: { [weak self] (pageProgress, artistName) in
                self?.statusSubject.send(.tags(artistName: artistName, progress: pageProgress))
            }
            .store(in: &cancelBag)

        let ignoredTags = self.ignoredTagService.ignoredTags()
        return getArtistsTags
            .flatMap { topTagsPage in
                self.artistService.updateArtist(
                    topTagsPage.artist,
                    with: topTagsPage.topTagsList.tags
                )
            }
            .flatMap { artist in
                return self.artistService.calculateTopTags(for: artist, ignoredTags: ignoredTags)
            }
            .collect()
            .map { _ in }
            .eraseToAnyPublisher()
    }

    // MARK: - Public methods

    public func requestData() {
        isLoadingSubject.send(true)

        let (progress, result) = requestLibrary()

        progress
            .sink { _ in
            } receiveValue: { [weak self] status in
                self?.statusSubject.send(status)
            }
            .store(in: &cancelBag)

        result.flatMap { _ -> AnyPublisher<Void, Error> in
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

    public func cancelPendingRequests() {
        statusSubject.send(.artistsFirstPage)
        cancelBag.forEach { $0.cancel() }
    }
}
