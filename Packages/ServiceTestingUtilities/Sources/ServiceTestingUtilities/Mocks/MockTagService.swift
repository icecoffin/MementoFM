//
//  MockTagService.swift
//  MementoFM
//
//  Created by Daniel on 22/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import TransientModels
import SharedServicesInterface

public final class MockTagService: TagServiceProtocol {
    public init() { }

    public var artists: [Artist] = []
    public var didRequestTopTags = false
    public var customTopTagsPages: [TopTagsPage] = []
    public func getTopTags(for artists: [Artist]) -> AnyPublisher<TopTagsPage, Error> {
        self.artists = artists
        didRequestTopTags = true
        return Publishers.Sequence(sequence: customTopTagsPages).eraseToAnyPublisher()
    }

    public var customTopTags: [Tag] = []
    public func getAllTopTags() -> [Tag] {
        return customTopTags
    }
}
