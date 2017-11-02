//
//  IgnoredTagService.swift
//  MementoFM
//
//  Created by Daniel on 20/08/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

class IgnoredTagService {
  private let realmService: RealmService
  private static let defaultIgnoredTagNames = ["rock", "metal", "indie", "alternative", "seen live", "under 2000 listeners"]

  init(realmService: RealmService) {
    self.realmService = realmService
  }

  func ignoredTags() -> [IgnoredTag] {
    return realmService.objects(IgnoredTag.self)
  }

  func createDefaultIgnoredTags(withNames names: [String] = IgnoredTagService.defaultIgnoredTagNames) -> Promise<Void> {
    let ignoredTags = names.map { name in
      return IgnoredTag(uuid: UUID().uuidString, name: name)
    }
    return realmService.save(ignoredTags)
  }

  func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> Promise<Void> {
    return realmService.deleteObjects(ofType: IgnoredTag.self).then {
      return self.realmService.save(ignoredTags)
    }
  }
}
