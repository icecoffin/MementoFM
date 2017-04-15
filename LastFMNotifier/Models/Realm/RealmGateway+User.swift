//
//  RealmGateway+User.swift
//  LastFMNotifier
//
//  Created by Daniel on 15/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

// MARK: User
extension RealmGateway {
  func clearLocalData(completion: (() -> Void)?) {
    write(block: { realm in
      self.deleteObjects(RealmArtist.self, in: realm)
      self.deleteObjects(RealmMilestones.self, in: realm)
    }, completion: completion)
  }
}
