//
//  TopTagsResponse.swift
//  MementoFM
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct TopTagsResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case topTagsList = "toptags"
    }

    let topTagsList: TopTagsList
}

extension TopTagsResponse {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let topTagsList = try container.decodeIfPresent(TopTagsList.self, forKey: .topTagsList) {
            self.topTagsList = topTagsList
        } else {
            self.topTagsList = TopTagsList(tags: [])
        }
    }
}

extension TopTagsResponse: Mappable {
    init(map: Mapper) throws {
        topTagsList = map.optionalFrom("toptags") ?? TopTagsList(tags: [])
    }
}
