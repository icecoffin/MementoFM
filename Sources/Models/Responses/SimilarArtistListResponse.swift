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

struct SimilarArtistList: Codable {
    private enum CodingKeys: String, CodingKey {
        case similarArtists = "artist"
    }

    let similarArtists: [SimilarArtist]
}

struct SimilarArtist: Codable {
    let name: String
}
