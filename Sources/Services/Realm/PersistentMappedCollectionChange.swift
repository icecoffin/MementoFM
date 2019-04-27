//
//  PersistentMappedCollectionChange.swift
//  MementoFM
//
//  Created by Dani on 26/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

enum PersistentMappedCollectionChange<CollectionType> {
  case initial(CollectionType)
  case update(CollectionType, deletions: [Int], insertions: [Int], modifications: [Int])
  case error(Error)
}

extension PersistentMappedCollectionChange {
  static func from(realmChange: RealmCollectionChange<CollectionType>) -> PersistentMappedCollectionChange<CollectionType> {
    switch realmChange {
    case .initial(let collectionType):
      return .initial(collectionType)
    case .update(let collectionType, let deletions, let insertions, let modifications):
      return .update(collectionType, deletions: deletions, insertions: insertions, modifications: modifications)
    case .error(let error):
      return .error(error)
    }
  }
}
