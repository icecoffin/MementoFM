//
//  RealmMappedCollection.swift
//  MementoFM
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMappedCollection<Element: Object, Transformed> {
  typealias Transform = (Element) -> Transformed

  private let realm: Realm
  lazy private var results: Results<Element> = {
    return self.fetchResults()
  }()
  private var transform: Transform
  private var notificationToken: NotificationToken?

  var sortDescriptors: [SortDescriptor] {
    didSet {
      refetchResults()
    }
  }

  var predicate: NSPredicate? {
    didSet {
      refetchResults()
    }
  }

  var notificationBlock: ((RealmCollectionChange<Results<Element>>) -> Void)?

  init(realm: Realm, predicate: NSPredicate? = nil, sortDescriptors: [SortDescriptor], transform: @escaping Transform) {
    self.realm = realm
    self.predicate = predicate
    self.sortDescriptors = sortDescriptors
    self.transform = transform

    subscribeToResultsNotifications()
  }

  deinit {
    notificationToken?.invalidate()
  }

  private func fetchResults() -> Results<Element> {
    let results = realm.objects(Element.self).sorted(by: sortDescriptors)
    if let predicate = predicate {
      return results.filter(predicate)
    }

    return results
  }

  private func refetchResults() {
    results = fetchResults()
    subscribeToResultsNotifications()
  }

  private func subscribeToResultsNotifications() {
    notificationToken?.invalidate()
    notificationToken = results.observe { [unowned self] changes in
      self.notificationBlock?(changes)
    }
  }

  var count: Int {
    return results.count
  }

  subscript(index: Int) -> Transformed {
    return transform(results[index])
  }

  var isEmpty: Bool {
    return results.isEmpty
  }
}
