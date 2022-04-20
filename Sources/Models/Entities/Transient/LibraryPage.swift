//
//  LibraryPage.swift
//  MementoFM
//
//  Created by Daniel on 06/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

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
}

extension LibraryPage {
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)

        if let artists = try? rootContainer.decodeIfPresent([Artist].self, forKey: .artists) {
            self.artists = artists
        } else {
            let singleArtist = try rootContainer.decode(Artist.self, forKey: .artists)
            self.artists = [singleArtist]
        }

        let attributesContainer = try rootContainer.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
        let indexString = try attributesContainer.decode(String.self, forKey: .index)
        index = int(from: indexString)

        let totalPagesString = try attributesContainer.decode(String.self, forKey: .totalPages)
        totalPages = int(from: totalPagesString)
    }
}
