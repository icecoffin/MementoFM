import UIKit
import Core

// MARK: - EnterUsernameCoordinatorFactoryProtocol

public protocol EnterUsernameCoordinatorFactoryProtocol {
    func makeEnterUsernameCoordinator(
        navigationController: UINavigationController,
        configuration: EnterUsernameCoordinator.Configuration
    ) -> EnterUsernameCoordinator
}

// MARK: - EnterUsernameCoordinatorFactory

public final class EnterUsernameCoordinatorFactory: EnterUsernameCoordinatorFactoryProtocol {
    private let dependencies: EnterUsernameDependencies

    public init(dependencies: EnterUsernameDependencies) {
        self.dependencies = dependencies
    }

    public func makeEnterUsernameCoordinator(
        navigationController: UINavigationController,
        configuration: EnterUsernameCoordinator.Configuration
    ) -> EnterUsernameCoordinator {
        EnterUsernameCoordinator(
            dependencies: dependencies,
            navigationController: navigationController,
            configuration: configuration
        )
    }
}
