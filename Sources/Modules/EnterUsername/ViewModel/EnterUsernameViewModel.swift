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
  private var currentUsername: String

  weak var delegate: EnterUsernameViewModelDelegate?

  var canSubmitUsername: Bool {
    return !currentUsername.isEmpty && currentUsername != dependencies.userDataStorage.username
  }

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    currentUsername = ""
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

  func updateUsername(_ username: String?) {
    currentUsername = username ?? ""
  }

  func submitUsername() {
    dependencies.userDataStorage.username = currentUsername
    clearLocalData().then {
      self.delegate?.enterUsernameViewModelDidFinish(self)
    }.noError()
  }

  private func clearLocalData() -> Promise<Void> {
    dependencies.userDataStorage.reset()
    return dependencies.realmGateway.clearLocalData()
  }
}
