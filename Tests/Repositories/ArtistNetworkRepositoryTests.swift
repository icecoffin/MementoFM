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
import PromiseKit
import Alamofire

class ArtistNetworkRepositoryTests: XCTestCase {
  func testGetLibraryPageRequestParametersAreCorrect() {
    let libraryPage = LibraryPage(index: 1, totalPages: 1, artists: [])
    let response = LibraryPageResponse(libraryPage: libraryPage)
    let networkService = StubNetworkService(response: response)
    let artistRepository = ArtistNetworkRepository(networkService: networkService)
    artistRepository.getLibraryPage(withIndex: 1, for: "User", limit: 10).then { _ -> Void in
      let expectedParameters: [String: AnyHashable] = ["method": "library.getartists",
                                                       "api_key": Keys.LastFM.apiKey,
                                                       "user": "User",
                                                       "format": "json",
                                                       "page": 1,
                                                       "limit": 10]
      expect(networkService.parameters as? [String: AnyHashable]).to(equal(expectedParameters))
      expect(networkService.encoding).to(beAKindOf(URLEncoding.self))
      expect(networkService.headers).to(beNil())
    }.noError()
  }

  func testGetSimilarArtistsRequestParametersAreCorrect() {
    let similarArtistList = SimilarArtistList(similarArtists: [])
    let response = SimilarArtistListResponse(similarArtistList: similarArtistList)
    let networkService = StubNetworkService(response: response)
    let artistRepository = ArtistNetworkRepository(networkService: networkService)

    let artist = ModelFactory.generateArtist()
    artistRepository.getSimilarArtists(for: artist, limit: 10).then { _ -> Void in
      let expectedParameters: [String: AnyHashable] = ["method": "artist.getsimilar",
                                                       "api_key": Keys.LastFM.apiKey,
                                                       "artist": artist.name,
                                                       "format": "json",
                                                       "limit": 10]
      expect(networkService.parameters as? [String: AnyHashable]).to(equal(expectedParameters))
      expect(networkService.encoding).to(beAKindOf(URLEncoding.self))
      expect(networkService.headers).to(beNil())
    }.noError()
  }
}
