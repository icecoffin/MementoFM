//
//  IgnoredTag.swift
//  LastFMNotifier
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

struct IgnoredTag {
  let uuid: String
  let name: String

  func updateName(_ newName: String) -> IgnoredTag {
    return IgnoredTag(uuid: uuid, name: newName)
  }
}
