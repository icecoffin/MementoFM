//
//  EnterUsernameViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol EnterUsernameViewModelDelegate: class {
  func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel)
  func enterUsernameViewModelDidRequestToClose(_ viewModel: EnterUsernameViewModel)
}

class EnterUsernameViewModel {
  private let realmGateway: RealmGateway
  private let userDataStorage: UserDataStorage

  weak var delegate: EnterUsernameViewModelDelegate?

  init(realmGateway: RealmGateway, userDataStorage: UserDataStorage) {
    self.realmGateway = realmGateway
    self.userDataStorage = userDataStorage
  }

  var usernameTextFieldPlaceholder: String {
    return "Enter your last.fm username".unlocalized
  }

  var submitButtonTitle: String {
    return "Submit".unlocalized
  }

  var currentUsernameText: String {
    if let username = userDataStorage.username {
      return "Current username:".unlocalized + " \(username)"
    } else {
      return ""
    }
  }

  func submitUsername(_ username: String) {
    let oldUsername = userDataStorage.username
    userDataStorage.username = username
    if oldUsername != username {
      _ = clearLocalData().then {
        self.delegate?.enterUsernameViewModelDidFinish(self)
      }
    } else {
      delegate?.enterUsernameViewModelDidFinish(self)
    }
  }

  private func clearLocalData() -> Promise<Void> {
    userDataStorage.reset()
    return realmGateway.clearLocalData()
  }

  func close() {
    delegate?.enterUsernameViewModelDidRequestToClose(self)
  }
}
