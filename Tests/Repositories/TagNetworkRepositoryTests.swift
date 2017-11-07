//
//  TagNetworkRepositoryTests.swift
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

class TagNetworkRepositoryTests: XCTestCase {
  func testGetTopTagsRequestParametersAreCorrect() {
    let topTagsList = TopTagsList(tags: [])
    let response = TopTagsResponse(topTagsList: topTagsList)
    let networkService = StubNetworkService(response: response)
    let tagRepository = TagNetworkRepository(networkService: networkService)
    tagRepository.getTopTags(for: "Artist").then { _ -> Void in
      let expectedParameters: [String: AnyHashable] = ["method": "artist.gettoptags",
                                                       "api_key": Keys.LastFM.apiKey,
                                                       "artist": "Artist",
                                                       "format": "json"]
      expect(networkService.parameters as? [String: AnyHashable]).to(equal(expectedParameters))
      expect(networkService.encoding).to(beAKindOf(URLEncoding.self))
      expect(networkService.headers).to(beNil())
    }.noError()
  }
}
