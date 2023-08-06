import UIKit

// MARK: - IgnoredTagsCoordinatorFactoryProtocol

public protocol IgnoredTagsCoordinatorFactoryProtocol {
    func makeIgnoredCoordinator(
        navigationController: UINavigationController,
        shouldAddDefaultTags: Bool,
        showAnimated: Bool
    ) -> any IgnoredTagsCoordinatorProtocol
}
