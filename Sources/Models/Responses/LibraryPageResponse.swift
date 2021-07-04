//
//  LibraryPageResponse.swift
//  MementoFM
//
//  Created by Daniel on 26/03/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct LibraryPageResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case libraryPage = "artists"
    }

    let libraryPage: LibraryPage
}

extension LibraryPageResponse: Mappable {
    init(map: Mapper) throws {
        libraryPage = try map.from("artists")
    }
}
