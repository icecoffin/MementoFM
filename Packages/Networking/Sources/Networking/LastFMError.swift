//
//  LastFMError.swift
//  MementoFM
//
//  Created by Daniel on 11/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

public struct LastFMError: Error, Codable {
    enum CodingKeys: String, CodingKey {
        case errorCode = "error"
        case message
    }

    public let errorCode: Int
    public let message: String
}
