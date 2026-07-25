//
//  MockArtistLibraryRepository.swift
//  MementoFM
//
//  Created by Daniel on 05/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine

final class MockArtistLibraryRepository: ArtistRepository {
    private let totalPages: Int
    private let artistProvider: ((Int) -> [Artist])
    private let shouldFailWithError: Bool

    init(totalPages: Int, shouldFailWithError: Bool, artistProvider: @escaping ((Int) -> [Artist])) {
        self.totalPages = totalPages
        self.shouldFailWithError = shouldFailWithError
        self.artistProvider = artistProvider
    }

    func getLibraryPage(
        withIndex index: Int,
        for user: String,
        limit: Int
    ) async throws -> LibraryPageResponse {
        if shouldFailWithError {
            throw NSError(domain: "MementoFM", code: 1, userInfo: nil)
        } else {
            let artists = artistProvider(index)
            let libraryPage = LibraryPage(index: index, totalPages: totalPages, artists: artists)
            return LibraryPageResponse(libraryPage: libraryPage)
        }
    }

    func getSimilarArtists(for artist: Artist, limit: Int) async throws -> SimilarArtistListResponse {
        fatalError()
    }
}
