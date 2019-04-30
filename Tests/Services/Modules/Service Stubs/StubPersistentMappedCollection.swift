//
//  StubPersistentMappedCollection.swift
//  MementoFM
//
//  Created by Dani on 30/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM

final class StubPersistentMappedCollection<Element: TransientEntity>: PersistentMappedCollection {
  var count = 0

  var isEmpty = false

  var sortDescriptors: [NSSortDescriptor] = []

  var predicate: NSPredicate?

  var elementForIndex: ((Int) -> Any)?
  subscript(index: Int) -> Element.PersistentType.TransientType {
    guard let element = elementForIndex?(index) as? Element.PersistentType.TransientType else {
      let typeString = "\(Element.PersistentType.TransientType.self)"
      fatalError("elementForIndex is either not set or is returning objects of a wrong type (should be of \(typeString)")
    }

    return element
  }
}
