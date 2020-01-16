//
//  MockIgnoredTagService.swift
//  MementoFM
//
//  Created by Daniel on 11/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class MockIgnoredTagService: IgnoredTagServiceProtocol {
    var defaultIgnoredTagNames: [String] = []

    var didRequestIgnoredTags = false
    var customIgnoredTags: [IgnoredTag] = []
    func ignoredTags() -> [IgnoredTag] {
        didRequestIgnoredTags = true
        return customIgnoredTags
    }

    var createdDefaultIgnoredTagNames: [String] = []
    func createDefaultIgnoredTags(withNames names: [String]) -> Promise<Void> {
        createdDefaultIgnoredTagNames = names
        return .value(())
    }

    var updatedIgnoredTags: [IgnoredTag] = []
    func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> Promise<Void> {
        updatedIgnoredTags = ignoredTags
        return .value(())
    }
}
