//
//  StubLibraryUpdater.swift
//  MementoFMTests
//
//  Created by Daniel on 01/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class StubLibraryUpdater: LibraryUpdaterProtocol {
  var onDidStartLoading: (() -> Void)?
  var onDidFinishLoading: (() -> Void)?
  var onDidChangeStatus: ((LibraryUpdateStatus) -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  var isFirstUpdate: Bool = true
  var lastUpdateTimestamp: TimeInterval = 0

  var didRequestData = false
  func requestData() {
    didRequestData = true
  }

  var didCancelPendingRequests = false
  func cancelPendingRequests() {
    didCancelPendingRequests = true
  }

  func simulateFinishLoading() {
    onDidFinishLoading?()
  }

  func simulateStatusChange(_ status: LibraryUpdateStatus) {
    onDidChangeStatus?(status)
  }

  func simulateError(_ error: Error) {
    onDidReceiveError?(error)
  }
}
