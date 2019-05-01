//
//  ApplicationStateObserver.swift
//  MementoFM
//
//  Created by Daniel on 04/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol ApplicationStateObserving: class {
  var onApplicationDidBecomeActive: (() -> Void)? { get set }
}

final class ApplicationStateObserver: ApplicationStateObserving {
  var onApplicationDidBecomeActive: (() -> Void)?
  private var isFirstLaunch = true

  init() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(applicationDidBecomeActive(_:)),
                                           name: UIApplication.didBecomeActiveNotification,
                                           object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
  }

  @objc private func applicationDidBecomeActive(_ notification: Notification) {
    if isFirstLaunch {
      isFirstLaunch = false
    } else {
      onApplicationDidBecomeActive?()
    }
  }
}
