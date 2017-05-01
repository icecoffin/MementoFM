//
//  EnterUsernameViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

enum EnterUsernameViewModelAction {
  case submit, cancel
}

protocol EnterUsernameViewModelDelegate: class {
  func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel)
}

class EnterUsernameViewModel {
  typealias Dependencies = HasRealmGateway & HasUserDataStorage

  private let dependencies: Dependencies
  weak var delegate: EnterUsernameViewModelDelegate?

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  var usernameTextFieldPlaceholder: String {
    return "Enter your last.fm username".unlocalized
  }

  var submitButtonTitle: String {
    return "Submit".unlocalized
  }

  var currentUsernameText: String {
    let username = dependencies.userDataStorage.username
    if username.isEmpty {
      return ""
    } else {
      return "Current username: ".unlocalized + "\(username)"
    }
  }

  func submitUsername(_ username: String) {
    let oldUsername = dependencies.userDataStorage.username
    dependencies.userDataStorage.username = username
    if oldUsername != username {
      _ = clearLocalData().then {
        self.delegate?.enterUsernameViewModelDidFinish(self)
      }
    } else {
      delegate?.enterUsernameViewModelDidFinish(self)
    }
  }

  private func clearLocalData() -> Promise<Void> {
    dependencies.userDataStorage.reset()
    return dependencies.realmGateway.clearLocalData()
  }
}
