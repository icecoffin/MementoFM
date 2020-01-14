//
//  LastFMErrorResponse.swift
//  MementoFM
//
//  Created by Daniel on 11/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct LastFMError: Error {
    let errorCode: Int
    let message: String
}

struct LastFMErrorResponse: Mappable {
    let error: LastFMError

    init(map: Mapper) throws {
        let errorCode: Int = try map.from("error")
        let message: String = try map.from("message")
        self.error = LastFMError(errorCode: errorCode, message: message)
    }
}
