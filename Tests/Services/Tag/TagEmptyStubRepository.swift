//
//  TagEmptyStubRepository.swift
//  MementoFM
//
//  Created by Daniel on 05/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class TagEmptyStubRepository: TagRepository {
    func getTopTags(for artist: String) -> Promise<TopTagsResponse> {
        fatalError()
    }
}
