//
//  RecentTracksPageResponse.swift
//  MementoFM
//
//  Created by Daniel on 26/03/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct RecentTracksPageResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case recentTracksPage = "recenttracks"
    }

    let recentTracksPage: RecentTracksPage
}

extension RecentTracksPageResponse: Mappable {
    init(map: Mapper) throws {
        recentTracksPage = try map.from("recenttracks")
    }
}
