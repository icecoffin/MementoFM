//
//  RealmGateway+Milestones.swift
//  LastFMNotifier
//
//  Created by Daniel on 15/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

// MARK: Milestones
extension RealmGateway {
  func milestones() -> Milestones {
    if let realmMilestones = defaultRealm.object(ofType: RealmMilestones.self, forPrimaryKey: RealmMilestones.uuid) {
      return realmMilestones.toTransient()
    }
    return Milestones(didReceiveInitialCollection: false, didReceiveInitialArtistTags: false)
  }

  func registerMilestone(ofType type: MilestoneType, completion: (() -> Void)? = nil) {
    write(block: { realm in
      let milestones: RealmMilestones
      if let realmMilestones = realm.object(ofType: RealmMilestones.self, forPrimaryKey: RealmMilestones.uuid) {
        milestones = realmMilestones
      } else {
        milestones = RealmMilestones()
        realm.add(milestones)
      }
      milestones.registerMilestone(ofType: type)
    }, completion: completion)
  }
}
