//
//  Tag.swift
//  MementoFM
//
//  Created by Daniel on 07/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

public struct Tag: Equatable, Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case count
    }

    public let name: String
    public let count: Int

    public init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}

extension Tag {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        self.name = name.lowercased()
        count = try container.decode(Int.self, forKey: .count)
    }
}
