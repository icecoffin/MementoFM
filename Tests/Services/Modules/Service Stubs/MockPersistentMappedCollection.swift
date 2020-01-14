//
//  MockPersistentMappedCollection.swift
//  MementoFMTests
//
//  Created by Dani on 13.01.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM

class MockPersistentMappedCollection<Element: TransientEntity>: PersistentMappedCollection {
  var values: [Element.PersistentType.TransientType]

  var count: Int {
    return values.count
  }

  var isEmpty: Bool {
    return values.isEmpty
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
