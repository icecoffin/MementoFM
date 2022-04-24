//
//  TopTagsList.swift
//  MementoFM
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

struct TopTagsList: Codable {
    static let maxTagCount = 30

    private enum CodingKeys: String, CodingKey {
        case tags = "tag"
    }

    let tags: [Tag]
}

extension TopTagsList {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tags = try container.decode([Tag].self, forKey: .tags)
        self.tags = Array(tags.prefix(Self.maxTagCount))
    }
}
