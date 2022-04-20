//
//  MockLibraryUpdater.swift
//  MementoFMTests
//
//  Created by Daniel on 01/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM

class MockLibraryUpdater: LibraryUpdaterProtocol {
    var didStartLoading: (() -> Void)?
    var didFinishLoading: (() -> Void)?
    var didChangeStatus: ((LibraryUpdateStatus) -> Void)?
    var didReceiveError: ((Error) -> Void)?

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

    func simulateStartLoading() {
        didStartLoading?()
    }

    func simulateFinishLoading() {
        didFinishLoading?()
    }

    func simulateStatusChange(_ status: LibraryUpdateStatus) {
        didChangeStatus?(status)
    }

    func simulateError(_ error: Error) {
        didReceiveError?(error)
    }
}
