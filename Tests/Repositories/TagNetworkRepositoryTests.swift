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
import Alamofire

final class TagNetworkRepositoryTests: XCTestCase {
    private var networkService: MockNetworkService!
    private var tagRepository: TagNetworkRepository!

    override func setUp() {
        super.setUp()

        networkService = MockNetworkService()
        tagRepository = TagNetworkRepository(networkService: networkService)
    }

    override func tearDown() {
        networkService = nil
        tagRepository = nil

        super.tearDown()
    }

    func test_getTopTags_callsNetworkServiceWithCorrectParameters() {
        let topTagsList = TopTagsList(tags: [])
        let response = TopTagsResponse(topTagsList: topTagsList)
        networkService.customResponse = response

        _ = tagRepository.getTopTags(for: "Artist")

        let expectedParameters: [String: AnyHashable] = ["method": "artist.gettoptags",
                                                         "api_key": Keys.LastFM.apiKey,
                                                         "artist": "Artist",
                                                         "format": "json"]

        let performRequestParameters = networkService.performRequestParameters
        expect(performRequestParameters?.parameters as? [String: AnyHashable]) == expectedParameters
        expect(performRequestParameters?.encoding).to(beAKindOf(URLEncoding.self))
        expect(performRequestParameters?.headers).to(beNil())
    }
}
