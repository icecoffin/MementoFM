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
import TransientModels

final class MockTagService: TagServiceProtocol {
    var artists: [Artist] = []
    var didRequestTopTags = false
    var customTopTagsPages: [TopTagsPage] = []
    func getTopTags(for artists: [Artist]) -> AnyPublisher<TopTagsPage, Error> {
        self.artists = artists
        didRequestTopTags = true
        return Publishers.Sequence(sequence: customTopTagsPages).eraseToAnyPublisher()
    }

    var customTopTags: [Tag] = []
    func getAllTopTags() -> [Tag] {
        return customTopTags
    }
}
