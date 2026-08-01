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

@MainActor
protocol EnterUsernameViewModelDelegate: AnyObject {
    func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel)
}

// MARK: - EnterUsernameViewModel

@MainActor
final class EnterUsernameViewModel {
    typealias Dependencies = HasUserService

    // MARK: - Private properties

    private let dependencies: Dependencies
    private var currentUsername: String

    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()
//    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Public properties

    var isLoading: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }

    var error: AnyPublisher<Error, Never> {
        return errorSubject.eraseToAnyPublisher()
    }

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

    func submitUsername() async {
        let userService = dependencies.userService
        isLoadingSubject.send(true)
        defer { isLoadingSubject.send(false) }

        do {
            _ = try await userService.checkUserExists(withUsername: currentUsername)
            userService.username = self.currentUsername
            try await userService.clearUserData()
            delegate?.enterUsernameViewModelDidFinish(self)
        } catch {
            errorSubject.send(error)
        }
    }
}
