//
//  MockTagService.swift
//  MementoFM
//
//  Created by Daniel on 22/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class MockTagService: TagServiceProtocol {
    var artists: [Artist] = []
    var customProgress: TopTagsRequestProgress?
    var didRequestTopTags = false
    func getTopTags(for artists: [Artist], progress: ((TopTagsRequestProgress) -> Promise<Void>)?) -> Promise<Void> {
        self.artists = artists
        didRequestTopTags = true
        if let progress = progress, let customProgress = customProgress {
            return progress(customProgress)
        } else {
            return .value(())
        }
    }

    var customTopTags: [Tag] = []
    func getAllTopTags() -> [Tag] {
        return customTopTags
    }
}
