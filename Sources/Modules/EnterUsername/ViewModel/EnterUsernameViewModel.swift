//
//  EnterUsernameViewModel.swift
//  MementoFM
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - EnterUsernameViewModelDelegate

protocol EnterUsernameViewModelDelegate: AnyObject {
    func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel)
}

// MARK: - EnterUsernameViewModel

final class EnterUsernameViewModel {
    typealias Dependencies = HasUserService

    // MARK: - Private properties

    private let dependencies: Dependencies
    private var currentUsername: String
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Public properties

    var didStartRequest: (() -> Void)?
    var didFinishRequest: (() -> Void)?
    var didReceiveError: ((Error) -> Void)?

    weak var delegate: EnterUsernameViewModelDelegate?

    var canSubmitUsername: Bool {
        return !currentUsername.isEmpty && currentUsername != dependencies.userService.username
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

    // MARK: - Init

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        currentUsername = ""
    }

    // MARK: - Public methods

    func updateUsername(_ username: String?) {
        currentUsername = username ?? ""
    }

    func submitUsername() {
        let userService = dependencies.userService
        didStartRequest?()
        userService.checkUserExists(withUsername: currentUsername)
            .flatMap { _ -> AnyPublisher<Void, Error> in
                userService.username = self.currentUsername
                return userService.clearUserData()
            }
            .sink { completion in
                self.didFinishRequest?()
                switch completion {
                case .finished:
                    self.delegate?.enterUsernameViewModelDidFinish(self)
                case .failure(let error):
                    self.didReceiveError?(error)
                }
            } receiveValue: { _ in }
            .store(in: &cancelBag)
    }
}
