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

  init(realmService: RealmService) {
    self.realmService = realmService
  }

  func hasIgnoredTags() -> Bool {
    return realmService.hasObjects(ofType: IgnoredTag.self)
  }

  func ignoredTags() -> [IgnoredTag] {
    return realmService.objects(IgnoredTag.self)
  }

  func createDefaultIgnoredTags() -> Promise<Void> {
    let ignoredTagNames = ["rock", "metal", "indie", "alternative", "seen live", "under 2000 listeners"]
    let ignoredTags = ignoredTagNames.map { name in
      return IgnoredTag(uuid: UUID().uuidString, name: name)
    }
    return realmService.save(ignoredTags)
  }

  func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> Promise<Void> {
    return realmService.save(ignoredTags)
  }
}