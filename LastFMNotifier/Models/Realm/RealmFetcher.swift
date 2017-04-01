//
//  RealmFetcher.swift
//  LastFMNotifier
//
//  Created by Daniel on 15/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmFetcher<Element: Object> {
  private let realm: Realm
  lazy private var results: Results<Element> = self.fetchResults()

  var sort: SortDescriptor {
    didSet {
      results = fetchResults()
    }
  }

  var predicate: NSPredicate? {
    didSet {
      results = fetchResults()
    }
  }

  init(realm: Realm, sort: SortDescriptor, predicate: NSPredicate? = nil) {
    self.realm = realm
    self.sort = sort
    self.predicate = predicate
  }

  private func fetchResults() -> Results<Element> {
    if let predicate = predicate {
      return realm.objects(Element.self).sorted(byKeyPath: sort.keyPath, ascending: sort.ascending).filter(predicate)
    } else {
      return realm.objects(Element.self).sorted(byKeyPath: sort.keyPath, ascending: sort.ascending)
    }
  }

  func addNotificationBlock(_ block: @escaping (RealmCollectionChange<Results<Element>>) -> Void) -> NotificationToken {
    return results.addNotificationBlock(block)
  }

  subscript(index: Int) -> Element {
    return results[index]
  }
}
