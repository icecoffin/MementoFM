//
//  PersistentMappedCollection.swift
//  MementoFM
//
//  Created by Dani on 27/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation

protocol PersistentMappedCollection {
  associatedtype Element: TransientEntity

  var count: Int { get }
  var isEmpty: Bool { get }
  var sortDescriptors: [NSSortDescriptor] { get set }
  var predicate: NSPredicate? { get set }

  subscript(index: Int) -> Element.PersistentType.TransientType { get }
}
