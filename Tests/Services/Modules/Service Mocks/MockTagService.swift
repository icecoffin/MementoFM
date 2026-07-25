//
//  MockTagService.swift
//  MementoFM
//
//  Created by Daniel on 22/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine

final class MockTagService: TagServiceProtocol {
    var artists: [Artist] = []
    var didRequestTopTags = false
    var customTopTagsPages: [TopTagsPage] = []
    func getTopTags(for artists: [Artist]) -> AsyncThrowingStream<TopTagsPage, any Error> {
        self.artists = artists
        didRequestTopTags = true
        return AsyncThrowingStream(elements: customTopTagsPages)
    }

    var customTopTags: [Tag] = []
    func getAllTopTags() -> [Tag] {
        return customTopTags
    }
}
