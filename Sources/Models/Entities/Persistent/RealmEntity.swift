//
//  RealmEntity.swift
//  MementoFM
//
//  Created by Daniel on 28/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol RealmEntity {
  associatedtype TransientType

  static func from(transient: TransientType) -> Self
  func toTransient() -> TransientType
}
