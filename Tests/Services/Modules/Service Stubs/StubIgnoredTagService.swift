//
//  StubIgnoredTagService.swift
//  MementoFM
//
//  Created by Daniel on 11/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class StubIgnoredTagService: IgnoredTagServiceProtocol {
    var defaultIgnoredTagNames: [String] = []

    var didRequestIgnoredTags = false
    var stubIgnoredTags: [IgnoredTag] = []
    func ignoredTags() -> [IgnoredTag] {
        didRequestIgnoredTags = true
        return stubIgnoredTags
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
