//
//  ArtistRepository.swift
//  MementoFM
//

import Foundation
import PromiseKit
import Combine

// MARK: - ArtistRepository

protocol ArtistRepository: AnyObject {
    func getLibraryPage(withIndex index: Int, for user: String, limit: Int) -> Promise<LibraryPageResponse>
    func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<SimilarArtistListResponse, Error>
}

// MARK: - ArtistNetworkRepository

final class ArtistNetworkRepository: ArtistRepository {
    // MARK: - Private properties

    private let networkService: NetworkService

    // MARK: - Init

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    // MARK: - Public methods

    func getLibraryPage(withIndex index: Int, for user: String, limit: Int) -> Promise<LibraryPageResponse> {
        let parameters: [String: Any] = ["method": "library.getartists",
                                         "api_key": Keys.LastFM.apiKey,
                                         "user": user,
                                         "format": "json",
                                         "page": index,
                                         "limit": limit]

        return networkService.performRequest(parameters: parameters)
    }

    func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<SimilarArtistListResponse, Error> {
        let parameters: [String: Any] = ["method": "artist.getsimilar",
                                         "api_key": Keys.LastFM.apiKey,
                                         "artist": artist.name,
                                         "format": "json",
                                         "limit": limit]

        return networkService.performRequest(parameters: parameters)
    }
}
