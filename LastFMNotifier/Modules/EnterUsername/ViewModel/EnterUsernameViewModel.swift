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
  func enterUsernameViewModel(_ viewModel: EnterUsernameViewModel, didFinishWithAction action: EnterUsernameViewModelAction)
}

class EnterUsernameViewModel {
  typealias Dependencies = HasRealmGateway & HasUserDataStorage

  private let dependencies: Dependencies
  weak var delegate: EnterUsernameViewModelDelegate?

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  var title: String {
    return "Welcome!".unlocalized
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
        self.delegate?.enterUsernameViewModel(self, didFinishWithAction: .submit)
      }
    } else {
      delegate?.enterUsernameViewModel(self, didFinishWithAction: .submit)
    }
  }

  private func clearLocalData() -> Promise<Void> {
    dependencies.userDataStorage.reset()
    return dependencies.realmGateway.clearLocalData()
  }

  func close() {
    delegate?.enterUsernameViewModel(self, didFinishWithAction: .cancel)
  }
}
