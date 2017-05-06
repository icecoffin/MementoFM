//
//  RealmHelpers.swift
//  LastFMNotifier
//
//  Created by Daniel on 05/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import RealmSwift
@testable import LastFMNotifier

extension RealmTag {
  convenience init(name: String, count: Int) {
    self.init()
    self.name = name
    self.count = count
  }
}
