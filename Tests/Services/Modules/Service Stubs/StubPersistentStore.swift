//
//  StubPersistentStore.swift
//  MementoFM
//
//  Created by Dani on 28/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class StubPersistentStore: PersistentStore {
  var customMappedCollection: Any?
  var mappedCollectionParameters: (predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor])?
  func mappedCollection<T: TransientEntity>(filteredUsing predicate: NSPredicate?,
                                            sortedBy sortDescriptors: [NSSortDescriptor]) -> AnyPersistentMappedCollection<T> {
    mappedCollectionParameters = (predicate, sortDescriptors)
    guard let customMappedCollection = customMappedCollection as? AnyPersistentMappedCollection<T> else {
      fatalError("customMappedCollection is either not set or has a wrong type (should be of \(T.self)")
    }
    return customMappedCollection
  }

  var customSavePromise: Promise<Void> = Promise { seal in seal.fulfill(()) }
  var saveParameters: (objects: [Any], update: Bool)?
  func save<T: TransientEntity>(_ objects: [T], update: Bool) -> Promise<Void>
    where T.PersistentType.TransientType == T {
      saveParameters = (objects: objects, update: update)
      return customSavePromise
  }

  var customDeletePromise: Promise<Void> = Promise { seal in seal.fulfill(()) }
  var didCallDelete = false
  var deletedObjectsTypeNames: [String] = []
  func deleteObjects<T: TransientEntity>(ofType type: T.Type) -> Promise<Void>
    where T.PersistentType.TransientType == T {
      didCallDelete = true
      deletedObjectsTypeNames.append(String(describing: type))
      return customDeletePromise
  }

  var customObjects: [Any] = []
  var objectsPredicate: NSPredicate?
  func objects<T: TransientEntity>(_ type: T.Type, filteredBy predicate: NSPredicate?) -> [T]
    where T.PersistentType.TransientType == T {
      guard let customObjects = customObjects as? [T.PersistentType.TransientType] else {
        fatalError("customObjects has an incorrect type (should be of \(T.self))")
      }
      objectsPredicate = predicate
      return customObjects
  }

  var customObjectForKey: Any?
  var objectPrimaryKeys: [String] = []
  func object<T: TransientEntity, K>(ofType type: T.Type, forPrimaryKey key: K) -> T?
    where T.PersistentType.TransientType == T {
      if let key = key as? String {
        objectPrimaryKeys.append(key)
      }

      guard let customObjectForKey = customObjectForKey else {
        return nil
      }

      guard let object = customObjectForKey as? T else {
        fatalError("customObject should be of type \(T.self)")
      }

      return object
  }
}
