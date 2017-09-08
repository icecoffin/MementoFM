//
//  ApplicationStateObserver.swift
//  MementoFM
//
//  Created by Daniel on 04/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class ApplicationStateObserver {
  var onApplicationDidBecomeActive: (() -> Void)?
  private var isFirstLaunch = true

  init() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(applicationDidBecomeActive(_:)),
                                           name: .UIApplicationDidBecomeActive,
                                           object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
  }

  @objc private func applicationDidBecomeActive(_ notification: Notification) {
    if isFirstLaunch {
      isFirstLaunch = false
    } else {
      onApplicationDidBecomeActive?()
    }
  }
}
