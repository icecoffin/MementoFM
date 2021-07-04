//
//  ErrorConverter.swift
//  MementoFM
//
//  Created by Daniel on 30/03/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

enum ErrorConverter {
    static func displayMessage(for error: Error) -> String {
        if let lastFMError = error as? LastFMError {
            return "\(lastFMError.message) (Error code: \(lastFMError.errorCode))"
        } else {
            return error.localizedDescription
        }
    }
}
