//
//  PageProgress.swift
//  MementoFM
//
//  Created by Dani on 14.04.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import Foundation

public struct PageProgress {
    public var current: Int
    public var total: Int

    public init(current: Int, total: Int) {
        self.current = current
        self.total = total
    }
}
