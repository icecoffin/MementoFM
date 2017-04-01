//
//  Mappable+FromAny.swift
//  LastFMNotifier
//
//  Created by Daniel on 26/03/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

extension Mappable {
  static func from(_ JSON: Any) throws -> Self {
    if let dictionary = JSON as? NSDictionary {
      return try self.init(map: Mapper(JSON: dictionary))
    } else {
      throw MapperError.convertibleError(value: JSON, type: Self.self)
    }
  }

  static func arrayFrom(_ JSON: Any) throws -> [Self] {
    if let array = JSON as? [NSDictionary] {
      return try array.map { try self.init(map: Mapper(JSON: $0)) }
    } else {
      throw MapperError.convertibleError(value: JSON, type: Self.self)
    }
  }
}
