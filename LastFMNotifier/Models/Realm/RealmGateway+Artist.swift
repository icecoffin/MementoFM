//
//  RealmGateway+Artist.swift
//  LastFMNotifier
//
//  Created by Daniel on 15/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

extension RealmGateway {
  func artistsNeedingTagsUpdate() -> [Artist] {
    let predicate = NSPredicate(format: "needsTagsUpdate == \(true)")
    return defaultRealm.objects(RealmArtist.self).filter(predicate).map({ $0.toTransient() })
  }
}
