//
//  Tag.swift
//  MementoFM
//
//  Created by Daniel on 07/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

struct Tag: Equatable, Codable {

    enum CodingKeys: String, CodingKey {
        case name
        case count
    }

    let name: String
    let count: Int
}

extension Tag {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        self.name = name.lowercased()
        count = try container.decode(Int.self, forKey: .count)
    }
}
