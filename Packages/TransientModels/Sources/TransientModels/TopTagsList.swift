//
//  TopTagsList.swift
//  MementoFM
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

public struct TopTagsList: Codable {
    public static let maxTagCount = 30

    private enum CodingKeys: String, CodingKey {
        case tags = "tag"
    }

    public let tags: [Tag]

    public init(tags: [Tag]) {
        self.tags = tags
    }
}

extension TopTagsList {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tags = try container.decode([Tag].self, forKey: .tags)
        self.tags = Array(tags.prefix(Self.maxTagCount))
    }
}
