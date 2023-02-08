//
//  TransientEntity.swift
//  MementoFM
//
//  Created by Dani on 08.02.2023.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import Foundation

public protocol TransientEntity {
    associatedtype PersistentType: PersistentEntity
}
