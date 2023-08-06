//
//  MockLibraryUpdater.swift
//  MementoFMTests
//
//  Created by Daniel on 01/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import SharedServicesInterface

public final class MockLibraryUpdater: LibraryUpdaterProtocol {
    public init() { }

    public var isLoadingSubject = PassthroughSubject<Bool, Never>()
    public var statusSubject = PassthroughSubject<LibraryUpdateStatus, Never>()
    public var errorSubject = PassthroughSubject<Error, Never>()

    public var isLoading: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }

    public var status: AnyPublisher<LibraryUpdateStatus, Never> {
        return statusSubject.eraseToAnyPublisher()
    }

    public var error: AnyPublisher<Error, Never> {
        return errorSubject.eraseToAnyPublisher()
    }

    public var isFirstUpdate: Bool = true
    public var lastUpdateTimestamp: TimeInterval = 0

    public var didRequestData = false
    public func requestData() {
        didRequestData = true
    }

    public var didCancelPendingRequests = false
    public func cancelPendingRequests() {
        didCancelPendingRequests = true
    }

    public func simulateStartLoading() {
        isLoadingSubject.send(true)
    }

    public func simulateFinishLoading() {
        isLoadingSubject.send(false)
    }

    public func simulateStatusChange(_ status: LibraryUpdateStatus) {
        statusSubject.send(status)
    }

    public func simulateError(_ error: Error) {
        errorSubject.send(error)
    }
}
