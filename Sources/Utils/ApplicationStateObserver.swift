//
//  ApplicationStateObserver.swift
//  MementoFM
//
//  Created by Daniel on 04/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import Combine

protocol ApplicationStateObserving: AnyObject {
    var applicationDidBecomeActive: AnyPublisher<Void, Never> { get }
}

final class ApplicationStateObserver: ApplicationStateObserving {
    private let notificationCenter: NotificationCenter
    private var cancelBag = Set<AnyCancellable>()

    private var applicationDidBecomeActiveSubject = PassthroughSubject<Void, Never>()

    var applicationDidBecomeActive: AnyPublisher<Void, Never> {
        return applicationDidBecomeActiveSubject.eraseToAnyPublisher()
    }

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter

        subscribeToNotifications()
    }

    private func subscribeToNotifications() {
        notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification)
            .dropFirst()
            .sink { [weak self] _ in
                self?.applicationDidBecomeActiveSubject.send()
            }
            .store(in: &cancelBag)
    }
}
