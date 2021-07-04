//
//  RecentTracksPage.swift
//  MementoFM
//
//  Created by Daniel on 06/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

struct RecentTracksPage: Codable {
    enum RootCodingKeys: String, CodingKey {
        case tracks = "track"
        case attributes = "@attr"
    }

    enum AttributesCodingKeys: String, CodingKey {
        case index = "page"
        case totalPages
    }

    let index: Int
    let totalPages: Int
    let tracks: [Track]
}

extension RecentTracksPage {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        tracks = try container.decode([Track].self, forKey: .tracks)

        let attributesContainer = try container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
        let indexString = try attributesContainer.decode(String.self, forKey: .index)
        index = int(from: indexString)

        let totalPagesString = try attributesContainer.decode(String.self, forKey: .totalPages)
        totalPages = int(from: totalPagesString)
    }
}
