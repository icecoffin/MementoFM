//
//  RealmGateway+Tag.swift
//  LastFMNotifier
//
//  Created by Daniel on 21/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift

// MARK: Tags
extension RealmGateway {
  func getAllTopTags() -> Promise<[Tag]> {
    return dispatch_promise(DispatchQueue.global()) { _ -> [Tag] in
      let artists = self.getCurrentQueueRealm().objects(RealmArtist.self)
      let allTopTags = artists.value(forKey: "topTags") as? [List<RealmTag>] ?? []
      return allTopTags.flatMap({ $0 }).map({ $0.toTransient() })
    }
  }
}
