//
//  MockPersistentMappedCollection.swift
//  MementoFMTests
//
//  Created by Dani on 13.01.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import Foundation
import PersistenceInterface
@testable import MementoFM

final class MockPersistentMappedCollection<Element: TransientEntity>: PersistentMappedCollection {
    var values: [Element.PersistentType.TransientType]

    var customCount: Int?
    var count: Int {
        return customCount ?? values.count
    }

    var customIsEmpty: Bool?
    var isEmpty: Bool {
        return customIsEmpty ?? values.isEmpty
    }

    var sortDescriptors: [NSSortDescriptor] = []
    var predicate: NSPredicate?

    init(values: [Element.PersistentType.TransientType]) {
        self.values = values
    }

    subscript(index: Int) -> Element.PersistentType.TransientType {
        return values[index]
    }
}
