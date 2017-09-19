//
//  ArtistListResponse.swift
//  MementoFM
//
//  Created by Daniel on 16/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct SimilarArtistListResponse {
  let similarArtistList: SimilarArtistList
}

extension SimilarArtistListResponse: Mappable {
  init(map: Mapper) throws {
    similarArtistList = try map.from("similarartists")
  }
}

struct SimilarArtistList {
  let similarArtists: [SimilarArtist]
}

extension SimilarArtistList: Mappable {
  init(map: Mapper) throws {
    similarArtists = try map.from("artist")
  }
}

struct SimilarArtist {
  let name: String
}

extension SimilarArtist: Mappable {
  init(map: Mapper) throws {
    name = try map.from("name")
  }
}
