//
//  RealmGateway.swift
//  LastFMNotifier
//
//  Created by Daniel on 18/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmGateway {
  let defaultRealm: Realm
  let getWriteRealm: () -> Realm

  init(defaultRealm: Realm, getWriteRealm: @escaping () -> Realm) {
    self.defaultRealm = defaultRealm
    self.getWriteRealm = getWriteRealm
  }

  func write(block: @escaping (Realm) -> Void, completion: (() -> Void)? = nil) {
    DispatchQueue.global(qos: .default).async {
      let backgroundRealm = self.getWriteRealm()
      self.write(to: backgroundRealm) { realm in
        block(realm)
      }
      DispatchQueue.main.async {
        self.defaultRealm.refresh()
        completion?()
      }
    }
  }

  fileprivate func write(to realm: Realm, block: (Realm) -> Void) {
    do {
      try realm.write {
        block(realm)
      }
    } catch {
      fatalError("Can't write to Realm")
    }
  }

  func save(objects: [Object], completion: (() -> Void)?) {
    DispatchQueue.global(qos: .default).async {
      let backgroundRealm = self.getWriteRealm()
      self.write(to: backgroundRealm) { realm in
        realm.add(objects, update: true)
      }
      DispatchQueue.main.async {
        self.defaultRealm.refresh()
        completion?()
      }
    }
  }

  fileprivate func deleteObjects<T: Object>(_ type: T.Type, in realm: Realm) {
    let objects = realm.objects(type)
    realm.delete(objects)
  }
}

// MARK: User
extension RealmGateway {
  func clearLocalData(completion: (() -> Void)?) {
    write(block: { realm in
    self.deleteObjects(RealmArtist.self, in: realm)
    self.deleteObjects(RealmMilestones.self, in: realm)
    }, completion: completion)
  }
}

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
