//
//  ArtistListResponse.swift
//  MementoFM
//
//  Created by Daniel on 16/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct SimilarArtistListResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case similarArtistList = "similarartists"
    }

    let similarArtistList: SimilarArtistList
}

extension SimilarArtistListResponse: Mappable {
    init(map: Mapper) throws {
        similarArtistList = try map.from("similarartists")
    }
}

struct SimilarArtistList: Codable {
    private enum CodingKeys: String, CodingKey {
        case similarArtists = "artist"
    }

    let similarArtists: [SimilarArtist]
}

extension SimilarArtistList: Mappable {
    init(map: Mapper) throws {
        similarArtists = try map.from("artist")
    }
}

struct SimilarArtist: Codable {
    let name: String
}

extension SimilarArtist: Mappable {
    init(map: Mapper) throws {
        name = try map.from("name")
    }
}
