//
//  MockArtistLibraryRepository.swift
//  MementoFM
//
//  Created by Daniel on 05/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
@testable import TransientModels
@testable import SharedServices

final class MockArtistLibraryRepository: ArtistRepository {
    private let totalPages: Int
    private let artistProvider: ((Int) -> [Artist])
    private let shouldFailWithError: Bool

    init(totalPages: Int, shouldFailWithError: Bool, artistProvider: @escaping ((Int) -> [Artist])) {
        self.totalPages = totalPages
        self.shouldFailWithError = shouldFailWithError
        self.artistProvider = artistProvider
    }

    func getLibraryPage(withIndex index: Int, for user: String, limit: Int) -> AnyPublisher<LibraryPageResponse, Error> {
        if shouldFailWithError {
            return Fail(error: NSError(domain: "MementoFM", code: 1, userInfo: nil)).eraseToAnyPublisher()
        } else {
            let artists = artistProvider(index)
            let libraryPage = LibraryPage(index: index, totalPages: totalPages, artists: artists)
            let response = LibraryPageResponse(libraryPage: libraryPage)
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<SimilarArtistListResponse, Error> {
        fatalError()
    }
}
