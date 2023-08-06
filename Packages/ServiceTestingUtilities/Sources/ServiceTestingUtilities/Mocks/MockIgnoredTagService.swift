//
//  MockIgnoredTagService.swift
//  MementoFM
//
//  Created by Daniel on 11/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import TransientModels
import SharedServicesInterface

public final class MockIgnoredTagService: IgnoredTagServiceProtocol {
    public init() { }

    public var defaultIgnoredTagNames: [String] = []

    public var didRequestIgnoredTags = false
    public var customIgnoredTags: [IgnoredTag] = []
    public func ignoredTags() -> [IgnoredTag] {
        didRequestIgnoredTags = true
        return customIgnoredTags
    }

    public var createdDefaultIgnoredTagNames: [String] = []
    public func createDefaultIgnoredTags(withNames names: [String]) -> AnyPublisher<Void, Error> {
        createdDefaultIgnoredTagNames = names
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public var updatedIgnoredTags: [IgnoredTag] = []
    public func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error> {
        updatedIgnoredTags = ignoredTags
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
