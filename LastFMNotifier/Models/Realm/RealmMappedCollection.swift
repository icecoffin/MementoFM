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
  lazy private var results: Results<Element> = self.fetchResults()
  private var transform: Transform
  private var notificationToken: NotificationToken?
  lazy private var mappedItemProvider: AnyRealmMappedItemProvider<Transformed> = self.createMappedItemProvider()

  // This is basically a sparse array - keys are indexes
  private var transformedCache: [Int: Transformed] = [:]

  var sort: SortDescriptor {
    didSet {
      mappedItemProvider.clear()
      results = fetchResults()
      subscribeToResultsNotifications()
    }
  }

  var predicate: NSPredicate? {
    didSet {
      mappedItemProvider.clear()
      results = fetchResults()
    }
  }

  var notificationBlock: ((RealmCollectionChange<Results<Element>>) -> Void)?

  init(realm: Realm, sort: SortDescriptor, transform: @escaping Transform) {
    self.realm = realm
    self.sort = sort
    self.transform = transform

    subscribeToResultsNotifications()
  }

  deinit {
    notificationToken?.stop()
  }

  private func createMappedItemProvider() -> AnyRealmMappedItemProvider<Transformed> {
    let provider: ((Int) -> Transformed) = { [unowned self] index in
      return self.transform(self.results[index])
    }
    return RealmMappedItemProviderFactory().provider(for: .recreate, using: provider)
  }

  private func fetchResults() -> Results<Element> {
    if let predicate = predicate {
      return realm.objects(Element.self).sorted(byKeyPath: sort.keyPath, ascending: sort.ascending).filter(predicate)
    } else {
      return realm.objects(Element.self).sorted(byKeyPath: sort.keyPath, ascending: sort.ascending)
    }
  }

  private func subscribeToResultsNotifications() {
    notificationToken = results.addNotificationBlock { [unowned self] changes in
      switch changes {
      case .initial:
        break
      case .update(_, let deletions, let insertions, let modifications):
        self.mappedItemProvider.handleUpdate(insertions: insertions, deletions: deletions, modifications: modifications)
        break
      case .error(let error):
        log.debug(ErrorConverter.displayMessage(for: error))
        break
      }
      self.notificationBlock?(changes)
    }
  }

  var count: Int {
    return results.count
  }

  subscript(index: Int) -> Transformed {
    return mappedItemProvider[index]
  }
}
