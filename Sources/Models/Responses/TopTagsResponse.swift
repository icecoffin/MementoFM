//
//  TopTagsResponse.swift
//  MementoFM
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct TopTagsResponse {
    let topTagsList: TopTagsList
}

extension TopTagsResponse: Mappable {
    init(map: Mapper) throws {
        topTagsList = map.optionalFrom("toptags") ?? TopTagsList(tags: [])
    }
}
