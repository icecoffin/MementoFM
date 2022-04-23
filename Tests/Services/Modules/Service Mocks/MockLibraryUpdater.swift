//
//  MockLibraryUpdater.swift
//  MementoFMTests
//
//  Created by Daniel on 01/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
@testable import MementoFM

final class MockLibraryUpdater: LibraryUpdaterProtocol {
    var isLoadingSubject = PassthroughSubject<Bool, Never>()
    var statusSubject = PassthroughSubject<LibraryUpdateStatus, Never>()
    var errorSubject = PassthroughSubject<Error, Never>()

    var isLoading: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }

    var status: AnyPublisher<LibraryUpdateStatus, Never> {
        return statusSubject.eraseToAnyPublisher()
    }

    var error: AnyPublisher<Error, Never> {
        return errorSubject.eraseToAnyPublisher()
    }

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
        isLoadingSubject.send(true)
    }

    func simulateFinishLoading() {
        isLoadingSubject.send(false)
    }

    func simulateStatusChange(_ status: LibraryUpdateStatus) {
        statusSubject.send(status)
    }

    func simulateError(_ error: Error) {
        errorSubject.send(error)
    }
}
