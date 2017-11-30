//
//  RealmMappedCollection.swift
//  MementoFM
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMappedCollection<Element: TransientEntity> where Element.RealmType: Object {
  typealias Transform = (Element.RealmType) -> Element

  private let realm: Realm
  lazy private var results: Results<Element.RealmType> = {
    return self.fetchResults()
  }()
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

  var notificationBlock: ((RealmCollectionChange<Results<Element.RealmType>>) -> Void)?

  init(realm: Realm, predicate: NSPredicate? = nil, sortDescriptors: [SortDescriptor]) {
    self.realm = realm
    self.predicate = predicate
    self.sortDescriptors = sortDescriptors

    subscribeToResultsNotifications()
  }

  deinit {
    notificationToken?.invalidate()
  }

  private func fetchResults() -> Results<Element.RealmType> {
    let results = realm.objects(Element.RealmType.self).sorted(by: sortDescriptors)
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

  subscript(index: Int) -> Element.RealmType.TransientType {
    return results[index].toTransient()
  }

  var isEmpty: Bool {
    return results.isEmpty
  }
}
