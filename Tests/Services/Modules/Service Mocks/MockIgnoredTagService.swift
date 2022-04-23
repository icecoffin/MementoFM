//
//  MockIgnoredTagService.swift
//  MementoFM
//
//  Created by Daniel on 11/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine

final class MockIgnoredTagService: IgnoredTagServiceProtocol {
    var defaultIgnoredTagNames: [String] = []

    var didRequestIgnoredTags = false
    var customIgnoredTags: [IgnoredTag] = []
    func ignoredTags() -> [IgnoredTag] {
        didRequestIgnoredTags = true
        return customIgnoredTags
    }

    var createdDefaultIgnoredTagNames: [String] = []
    func createDefaultIgnoredTags(withNames names: [String]) -> AnyPublisher<Void, Error> {
        createdDefaultIgnoredTagNames = names
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    var updatedIgnoredTags: [IgnoredTag] = []
    func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error> {
        updatedIgnoredTags = ignoredTags
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
