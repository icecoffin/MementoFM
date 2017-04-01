//
//  SearchState.swift
//  LastFMNotifier
//
//  Created by Daniel on 08/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

struct SearchState {
  var previousSearch = ""
  var currentSearch = ""

  mutating func finishCurrentSearch() {
    previousSearch = currentSearch
  }

  var hasPreviousSearch: Bool {
    return !previousSearch.isEmpty
  }

  var predicate: NSPredicate? {
    return currentSearch.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@", currentSearch)
  }
}
