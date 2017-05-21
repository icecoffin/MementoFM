//
//  IgnoredTag.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

struct IgnoredTag {
  let uuid: String
  let name: String

  func byUpdatingName(_ newName: String) -> IgnoredTag {
    return IgnoredTag(uuid: uuid, name: newName)
  }
}
