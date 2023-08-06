import UIKit
import IgnoredTagsInterface

// MARK: - IgnoredTagsCoordinatorFactory

public final class IgnoredTagsCoordinatorFactory: IgnoredTagsCoordinatorFactoryProtocol {
    private let dependencies: IgnoredTagsDependencies

    public init(dependencies: IgnoredTagsDependencies) {
        self.dependencies = dependencies
    }

    public func makeIgnoredCoordinator(
        navigationController: UINavigationController,
        shouldAddDefaultTags: Bool,
        showAnimated: Bool
    ) -> any IgnoredTagsCoordinatorProtocol {
        IgnoredTagsCoordinator(
            dependencies: dependencies,
            navigationController: navigationController,
            shouldAddDefaultTags: shouldAddDefaultTags,
            showAnimated: showAnimated
        )
    }
}
