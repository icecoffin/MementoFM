//
//  EnterUsernameViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 07/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
import Nimble
import Combine
@testable import MementoFM

final class EnterUsernameViewModelTests: XCTestCase {
    private final class Dependencies: EnterUsernameViewModel.Dependencies {
        let userService: UserServiceProtocol

        init(userService: UserServiceProtocol) {
            self.userService = userService
        }
    }

    private var cancelBag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        cancelBag = .init()
    }

    override func tearDown() {
        cancelBag = nil

        super.tearDown()
    }

    func test_canSubmitUsername_returnsFalse_forEmptyUsername() {
        let dependencies = Dependencies(userService: MockUserService())
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)

        expect(viewModel.canSubmitUsername) == false
    }

    func test_canSubmitUsername_returnsTrue_forNewUsername() {
        let dependencies = Dependencies(userService: MockUserService())
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)

        dependencies.userService.username = "foo"
        viewModel.updateUsername("username")

        expect(viewModel.canSubmitUsername) == true
    }

    func test_canSubmitUsername_returnsFalse_forExistingUsername() {
        let dependencies = Dependencies(userService: MockUserService())
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)

        viewModel.updateUsername("username")
        dependencies.userService.username = "username"

        expect(viewModel.canSubmitUsername) == false
    }

    func test_currentUsername_returnsEmptyString_ifNoUsernameIsSet() {
        let dependencies = Dependencies(userService: MockUserService())
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)

        expect(viewModel.currentUsernameText).to(beEmpty())
    }

    func test_currentUsername_returnsCorrectValue_basedOnUserService() {
        let dependencies = Dependencies(userService: MockUserService())

        let viewModel = EnterUsernameViewModel(dependencies: dependencies)
        dependencies.userService.username = "username"

        expect(viewModel.currentUsernameText) == viewModel.currentUsernamePrefix + "username"
    }

    func test_submitUsername_startsAndFinishesLoading() {
        let userService = MockUserService()
        let dependencies = Dependencies(userService: userService)
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)

        var loadingStates: [Bool] = []

        viewModel.isLoading.sink(receiveValue: { isLoading in
            loadingStates.append(isLoading)
        })
        .store(in: &cancelBag)

        viewModel.updateUsername("username")
        viewModel.submitUsername()

        expect(loadingStates) == [true, false]
    }

    func test_submitUsername_notifiesDelegateOnSuccess() {
        final class TestEnterUsernameViewModelDelegate: EnterUsernameViewModelDelegate {
            var didCallEnterUsernameViewModelDidFinish = false
            func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
                didCallEnterUsernameViewModelDidFinish = true
            }
        }

        let userService = MockUserService()
        let dependencies = Dependencies(userService: userService)
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)

        let delegate = TestEnterUsernameViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.updateUsername("username")
        viewModel.submitUsername()

        expect(delegate.didCallEnterUsernameViewModelDidFinish) == true
    }

    func test_submitUsername_checksThatUsernameExists() {
        let userService = MockUserService()
        let dependencies = Dependencies(userService: userService)
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)

        viewModel.updateUsername("username")
        viewModel.submitUsername()

        expect(userService.usernameBeingChecked) == "username"
    }

    func test_submitUsername_clearsUserDataOnSuccess() {
        let userService = MockUserService()
        let dependencies = Dependencies(userService: userService)
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)

        viewModel.updateUsername("username")
        viewModel.submitUsername()

        expect(userService.didCallClearUserData) == true
    }

    func test_submitUsername_emitsError() {
        final class TestEnterUsernameViewModelDelegate: EnterUsernameViewModelDelegate {
            func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
                // Test that delegate is not notified
                fail()
            }
        }

        let userService = MockUserService()
        userService.shouldFinishWithSuccess = false
        let dependencies = Dependencies(userService: userService)
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)

        var didReceiveError = false

        viewModel.error
            .sink(receiveValue: { _ in
                didReceiveError = true
            })
            .store(in: &cancelBag)

        let delegate = TestEnterUsernameViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.updateUsername("username")
        viewModel.submitUsername()

        expect(didReceiveError) == true
    }
}
