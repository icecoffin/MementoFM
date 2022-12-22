//
//  ArtistNetworkRepositoryTests.swift
//  MementoFMTests
//
//  Created by Daniel on 07/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import Alamofire
@testable import TransientModels

final class ArtistNetworkRepositoryTests: XCTestCase {
    private var networkService: MockNetworkService!
    private var artistRepository: ArtistNetworkRepository!

    override func setUp() {
        super.setUp()

        networkService = MockNetworkService()
        artistRepository = ArtistNetworkRepository(networkService: networkService)
    }

    override func tearDown() {
        networkService = nil
        artistRepository = nil

        super.tearDown()
    }

    func test_getLibraryPage_callsNetworkServiceWithCorrectParameters() {
        let libraryPage = LibraryPage(index: 1, totalPages: 1, artists: [])
        let response = LibraryPageResponse(libraryPage: libraryPage)
        networkService.customResponse = response

        _ = artistRepository.getLibraryPage(withIndex: 1, for: "User", limit: 10)

        let expectedParameters: [String: AnyHashable] = ["method": "library.getartists",
                                                         "api_key": Keys.LastFM.apiKey,
                                                         "user": "User",
                                                         "format": "json",
                                                         "page": 1,
                                                         "limit": 10]

        let performRequestParameters = networkService.performRequestParameters
        expect(performRequestParameters?.parameters as? [String: AnyHashable]) == expectedParameters
        expect(performRequestParameters?.encoding).to(beAKindOf(URLEncoding.self))
        expect(performRequestParameters?.headers).to(beNil())
    }

    func test_getSimilarArtists_callsNetworkServiceWithCorrectParameters() {
        let similarArtistList = SimilarArtistList(similarArtists: [])
        let response = SimilarArtistListResponse(similarArtistList: similarArtistList)
        networkService.customResponse = response

        let artist = ModelFactory.generateArtist()
        _ = artistRepository.getSimilarArtists(for: artist, limit: 10)

        let expectedParameters: [String: AnyHashable] = ["method": "artist.getsimilar",
                                                         "api_key": Keys.LastFM.apiKey,
                                                         "artist": artist.name,
                                                         "format": "json",
                                                         "limit": 10]

        let performRequestParameters = networkService.performRequestParameters
        expect(performRequestParameters?.parameters as? [String: AnyHashable]) == expectedParameters
        expect(performRequestParameters?.encoding).to(beAKindOf(URLEncoding.self))
        expect(performRequestParameters?.headers).to(beNil())
    }
}
