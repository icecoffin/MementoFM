//
//  LastFMError+LocalizedDescription.swift
//  MementoFM
//
//  Created by Dani on 19.02.2023.
//  Copyright © 2023 icecoffin. All rights reserved.
//

import Foundation
import Networking

extension LastFMError: LocalizedError {
    public var errorDescription: String? {
        return "\(message) (Error code: \(errorCode))".unlocalized
    }
}
