//
//  ArtistSimilarsStubRepository.swift
//  MementoFM
//
//  Created by Daniel on 05/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class ArtistSimilarsStubRepository: ArtistRepository {
    private let shouldFailWithError: Bool
    private let similarArtistProvider: (() -> [SimilarArtist])

    init(shouldFailWithError: Bool, similarArtistProvider: @escaping (() -> [SimilarArtist])) {
        self.shouldFailWithError = shouldFailWithError
        self.similarArtistProvider = similarArtistProvider
    }

    func getLibraryPage(withIndex index: Int, for user: String, limit: Int) -> Promise<LibraryPageResponse> {
        fatalError()
    }

    var getSimilarArtistsParameters: (artist: Artist, limit: Int)?
    func getSimilarArtists(for artist: Artist, limit: Int) -> Promise<SimilarArtistListResponse> {
        getSimilarArtistsParameters = (artist, limit)
        if shouldFailWithError {
            return Promise(error: NSError(domain: "MementoFM", code: 1, userInfo: nil))
        } else {
            let similarArtists = similarArtistProvider()
            let similarArtistList = SimilarArtistList(similarArtists: similarArtists)
            let response = SimilarArtistListResponse(similarArtistList: similarArtistList)
            return .value(response)
        }
    }
}
