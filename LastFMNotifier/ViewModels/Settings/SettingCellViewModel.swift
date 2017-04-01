//
//  SettingCellViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 23/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

class SettingCellViewModel {
  private let configuration: SettingConfiguration

  init(configuration: SettingConfiguration) {
    self.configuration = configuration
  }

  var title: String {
    return configuration.title
  }

  func fireAction() {
    configuration.action()
  }
}
