import UIKit
import Core

// MARK: - SyncCoordinatorFactoryProtocol

public protocol SyncCoordinatorFactoryProtocol {
    func makeSyncCoordinator(navigationController: UINavigationController) -> SyncCoordinator
}

// MARK: - SyncCoordinatorFactory

public final class SyncCoordinatorFactory: SyncCoordinatorFactoryProtocol {
    private let dependencies: SyncDependencies

    public init(dependencies: SyncDependencies) {
        self.dependencies = dependencies
    }

    public func makeSyncCoordinator(navigationController: UINavigationController) -> SyncCoordinator {
        SyncCoordinator(navigationController: navigationController, dependencies: dependencies)
    }
}
