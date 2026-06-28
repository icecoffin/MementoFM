//
//  ArtistRepository.swift
//  MementoFM
//

import Foundation
import Combine

// MARK: - ArtistRepository

protocol ArtistRepository: AnyObject {
    func getLibraryPage(
        withIndex index: Int,
        for user: String,
        limit: Int
    ) async throws -> LibraryPageResponse

    func getSimilarArtists(
        for artist: Artist,
        limit: Int
    ) async throws -> SimilarArtistListResponse
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

    func getLibraryPage(
        withIndex index: Int,
        for user: String,
        limit: Int
    ) async throws -> LibraryPageResponse {
        let parameters: [String: Any] = ["method": "library.getartists",
                                         "api_key": Keys.LastFM.apiKey,
                                         "user": user,
                                         "format": "json",
                                         "page": index,
                                         "limit": limit]

        return try await networkService.performRequest(parameters: parameters)
    }

    func getSimilarArtists(
        for artist: Artist,
        limit: Int
    ) async throws -> SimilarArtistListResponse {
        let parameters: [String: Any] = ["method": "artist.getsimilar",
                                         "api_key": Keys.LastFM.apiKey,
                                         "artist": artist.name,
                                         "format": "json",
                                         "limit": limit]

        return try await networkService.performRequest(parameters: parameters)
    }
}
