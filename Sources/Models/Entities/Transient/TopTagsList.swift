//
//  TopTagsList.swift
//  MementoFM
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct TopTagsList: Codable {
    private enum CodingKeys: String, CodingKey {
        case tags = "tag"
    }

    let tags: [Tag]
}

extension TopTagsList: Mappable {
    init(map: Mapper) throws {
        tags = try map.from("tag")
    }
}
