//
//  MockArtistSimilarsRepository.swift
//  MementoFM
//
//  Created by Daniel on 05/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import TransientModels
@testable import SharedServices
import ServiceTestingUtilities

final class MockArtistSimilarsRepository: ArtistRepository {
    private let shouldFailWithError: Bool
    private let similarArtistProvider: (() -> [SimilarArtist])

    init(shouldFailWithError: Bool, similarArtistProvider: @escaping (() -> [SimilarArtist])) {
        self.shouldFailWithError = shouldFailWithError
        self.similarArtistProvider = similarArtistProvider
    }

    func getLibraryPage(withIndex index: Int, for user: String, limit: Int) -> AnyPublisher<LibraryPageResponse, Error> {
        fatalError()
    }

    var getSimilarArtistsParameters: (artist: Artist, limit: Int)?
    func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<SimilarArtistListResponse, Error> {
        getSimilarArtistsParameters = (artist, limit)
        if shouldFailWithError {
            return Fail(error: NSError(domain: "MementoFM", code: 1, userInfo: nil))
                .eraseToAnyPublisher()
        } else {
            let similarArtists = similarArtistProvider()
            let similarArtistList = SimilarArtistList(similarArtists: similarArtists)
            let response = SimilarArtistListResponse(similarArtistList: similarArtistList)
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
