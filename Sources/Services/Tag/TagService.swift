//
//  TagService.swift
//  MementoFM
//
//  Created by Daniel on 10/08/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

class TagService {
  private let realmService: RealmService

  init(realmService: RealmService) {
    self.realmService = realmService
  }

  func getAllTopTags() -> Promise<[Tag]> {
    return dispatch_promise(DispatchQueue.global()) { _ -> [Tag] in
      let artists = self.realmService.objects(Artist.self)
      return artists.flatMap { return $0.topTags }
    }
  }
}
