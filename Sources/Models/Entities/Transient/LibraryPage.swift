//
//  LibraryPage.swift
//  MementoFM
//
//  Created by Daniel on 06/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct LibraryPage: Codable {
    enum RootCodingKeys: String, CodingKey {
        case artists = "artist"
        case attributes = "@attr"
    }

    enum AttributesCodingKeys: String, CodingKey {
        case index = "page"
        case totalPages
    }

    let index: Int
    let totalPages: Int
    let artists: [Artist]

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)

        artists = try rootContainer.decode([Artist].self, forKey: .artists)

        let attributesContainer = try rootContainer.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
        let indexString = try attributesContainer.decode(String.self, forKey: .index)
        index = int(from: indexString)

        let totalPagesString = try attributesContainer.decode(String.self, forKey: .totalPages)
        totalPages = int(from: totalPagesString)
    }
}

extension LibraryPage: Mappable {
    init(map: Mapper) throws {
        try index = map.from("@attr.page") { int(from: $0) }
        try totalPages = map.from("@attr.totalPages") { int(from: $0) }
        try artists = map.from("artist")
    }
}
