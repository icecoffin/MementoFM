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
    func createDefaultIgnoredTags(withNames names: [String]) async throws {
        createdDefaultIgnoredTagNames = names
    }

    var updatedIgnoredTags: [IgnoredTag] = []
    func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) async throws {
        updatedIgnoredTags = ignoredTags
    }
}
