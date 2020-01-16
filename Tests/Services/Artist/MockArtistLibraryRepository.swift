//
//  MockArtistLibraryRepository.swift
//  MementoFM
//
//  Created by Daniel on 05/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class MockArtistLibraryRepository: ArtistRepository {
    private let totalPages: Int
    private let artistProvider: ((Int) -> [Artist])
    private let shouldFailWithError: Bool

    init(totalPages: Int, shouldFailWithError: Bool, artistProvider: @escaping ((Int) -> [Artist])) {
        self.totalPages = totalPages
        self.shouldFailWithError = shouldFailWithError
        self.artistProvider = artistProvider
    }

    func getLibraryPage(withIndex index: Int, for user: String, limit: Int) -> Promise<LibraryPageResponse> {
        if shouldFailWithError {
            return Promise(error: NSError(domain: "MementoFM", code: 1, userInfo: nil))
        } else {
            let artists = artistProvider(index)
            let libraryPage = LibraryPage(index: index, totalPages: totalPages, artists: artists)
            let response = LibraryPageResponse(libraryPage: libraryPage)
            return .value(response)
        }
    }

    func getSimilarArtists(for artist: Artist, limit: Int) -> Promise<SimilarArtistListResponse> {
        fatalError()
    }
}
