//
//  LastFMErrorResponse.swift
//  MementoFM
//
//  Created by Daniel on 11/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct LastFMError: Error, Codable {
    enum CodingKeys: String, CodingKey {
        case errorCode = "error"
        case message
    }

    let errorCode: Int
    let message: String

    var error: LastFMError {
        return LastFMError(errorCode: errorCode, message: message)
    }
}
