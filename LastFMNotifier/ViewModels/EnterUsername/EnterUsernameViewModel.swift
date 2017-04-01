//
//  EnterUsernameViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

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

  var usernameTextFieldPlacerholder: String {
    return NSLocalizedString("Enter your last.fm username", comment: "")
  }

  var submitButtonTitle: String {
    return NSLocalizedString("Submit", comment: "")
  }

  var currentUsernameText: String {
    if let username = userDataStorage.username {
      return NSLocalizedString("Current username:", comment: "") + " \(username)"
    } else {
      return ""
    }
  }

  func submitUsername(_ username: String) {
    let oldUsername = userDataStorage.username
    userDataStorage.username = username
    if oldUsername != username {
      clearLocalData {
        self.delegate?.enterUsernameViewModelDidFinish(self)
      }
    } else {
      delegate?.enterUsernameViewModelDidFinish(self)
    }
  }

  private func clearLocalData(completion: @escaping () -> Void) {
    realmGateway.clearLocalData(completion: completion)
    userDataStorage.lastUpdateTimestamp = 0
  }

  func close() {
    delegate?.enterUsernameViewModelDidRequestToClose(self)
  }
}
