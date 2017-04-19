//
//  RealmGateway+User.swift
//  LastFMNotifier
//
//  Created by Daniel on 15/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: User
extension RealmGateway {
  func clearLocalData() -> Promise<Void> {
    return write(block: { realm in
      self.deleteObjects(RealmArtist.self, in: realm)
    })
  }
}
