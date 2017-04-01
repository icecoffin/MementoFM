//
//  RealmMilestones.swift
//  LastFMNotifier
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMilestones: Object {
  static let uuid = "40f909aa-5a58-4d05-bfe4-84201b13b681"

  dynamic var uuid: String = RealmMilestones.uuid
  dynamic var didReceiveInitialCollection: Bool = false
  dynamic var didReceiveInitialArtistTags: Bool = false

  override static func primaryKey() -> String? {
    return "uuid"
  }

  class func from(milestones: Milestones) -> RealmMilestones {
    let realmMilestones = RealmMilestones()
    realmMilestones.didReceiveInitialCollection = milestones.didReceiveInitialCollection
    realmMilestones.didReceiveInitialArtistTags = milestones.didReceiveInitialArtistTags
    return realmMilestones
  }

  func toTransient() -> Milestones {
    return Milestones(didReceiveInitialCollection: didReceiveInitialCollection,
                      didReceiveInitialArtistTags: didReceiveInitialArtistTags)
  }
}
