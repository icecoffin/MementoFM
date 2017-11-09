//
//  EnterUsernameViewModel.swift
//  MementoFM
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
  typealias Dependencies = HasUserService

  private let dependencies: Dependencies
  private var currentUsername: String

  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  weak var delegate: EnterUsernameViewModelDelegate?

  var canSubmitUsername: Bool {
    return !currentUsername.isEmpty && currentUsername != dependencies.userService.username
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

  var currentUsernamePrefix: String {
    return "Current username: ".unlocalized
  }

  var currentUsernameText: String {
    let username = dependencies.userService.username
    if username.isEmpty {
      return ""
    } else {
      return currentUsernamePrefix + username
    }
  }

  func updateUsername(_ username: String?) {
    currentUsername = username ?? ""
  }

  func submitUsername() {
    let userService = dependencies.userService
    onDidStartRequest?()
    userService.checkUserExists(withUsername: currentUsername).then { _ in
      userService.username = self.currentUsername
      return userService.clearUserData()
    }.then {
      self.delegate?.enterUsernameViewModelDidFinish(self)
    }.catch { error in
      self.onDidReceiveError?(error)
    }.always {
      self.onDidFinishRequest?()
    }
  }
}
