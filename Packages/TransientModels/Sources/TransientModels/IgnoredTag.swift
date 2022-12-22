//
//  IgnoredTag.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

public struct IgnoredTag: Equatable {
    public let uuid: String
    public let name: String

    public init(uuid: String, name: String) {
        self.uuid = uuid
        self.name = name
    }

    public func updatingName(_ newName: String) -> IgnoredTag {
        return IgnoredTag(uuid: uuid, name: newName)
    }
}
