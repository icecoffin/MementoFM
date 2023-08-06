//
//  MockPersistentMappedCollection.swift
//  MementoFMTests
//
//  Created by Dani on 13.01.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import Foundation
import PersistenceInterface

public final class MockPersistentMappedCollection<Element: TransientEntity>: PersistentMappedCollection {
    public var values: [Element.PersistentType.TransientType]

    public var customCount: Int?
    public var count: Int {
        return customCount ?? values.count
    }

    public var customIsEmpty: Bool?
    public var isEmpty: Bool {
        return customIsEmpty ?? values.isEmpty
    }

    public var sortDescriptors: [NSSortDescriptor] = []
    public var predicate: NSPredicate?

    public init(values: [Element.PersistentType.TransientType]) {
        self.values = values
    }

    public subscript(index: Int) -> Element.PersistentType.TransientType {
        return values[index]
    }
}
