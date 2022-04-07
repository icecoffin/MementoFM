//
//  Logger.swift
//  MementoFM
//
//  Created by Dani on 07.04.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import Foundation

final class Logger {
    static func debug(_ message: @autoclosure () -> Any) {
        #if DEBUG
        // swiftlint:disable:next print_usage
        print("\(Date()) [DEBUG] \(message())")
        #endif
    }
}
