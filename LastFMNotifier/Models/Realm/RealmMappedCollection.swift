//
//  RealmMappedCollection.swift
//  LastFMNotifier
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

  // This is basically a sparse array - keys are indexes
  private var transformedCache: [Int: Transformed] = [:]

  var sortDescriptors: [SortDescriptor] {
    didSet {
      results = fetchResults()
      subscribeToResultsNotifications()
    }
  }

  var predicate: NSPredicate? {
    didSet {
      results = fetchResults()
    }
  }

  var notificationBlock: ((RealmCollectionChange<Results<Element>>) -> Void)?

  init(realm: Realm, sortDescriptors: [SortDescriptor], transform: @escaping Transform) {
    self.realm = realm
    self.sortDescriptors = sortDescriptors
    self.transform = transform

    subscribeToResultsNotifications()
  }

  deinit {
    notificationToken?.stop()
  }

  private func fetchResults() -> Results<Element> {
    let results = realm.objects(Element.self).sorted(by: sortDescriptors)
    if let predicate = predicate {
      return results.filter(predicate)
    } else {
      return results
    }
  }

  private func subscribeToResultsNotifications() {
    notificationToken = results.addNotificationBlock { [unowned self] changes in
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
