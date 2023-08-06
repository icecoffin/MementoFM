import UIKit
import Core
import CoreUI
import IgnoredTagsInterface

// MARK: - IgnoredTagsCoordinator

public final class IgnoredTagsCoordinator: IgnoredTagsCoordinatorProtocol {
    // MARK: - Private properties

    private let dependencies: IgnoredTagsDependencies
    private let shouldAddDefaultTags: Bool
    private let showAnimated: Bool

    // MARK: - Public properties

    public let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []
    public var didFinish: (() -> Void)?

    public weak var delegate: IgnoredTagsCoordinatorDelegate?

    // MARK: - Init

    public init(
        dependencies: IgnoredTagsDependencies,
        navigationController: UINavigationController,
        shouldAddDefaultTags: Bool,
        showAnimated: Bool
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
        self.shouldAddDefaultTags = shouldAddDefaultTags
        self.showAnimated = showAnimated
    }

    // MARK: - Public methods

    public func start() {
        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: shouldAddDefaultTags)
        viewModel.delegate = self
        let viewController = IgnoredTagsViewController(viewModel: viewModel)
        viewController.title = "Ignored Tags".unlocalized

        let addButton = BlockBarButtonItem(image: .plus, style: .plain) { [unowned viewModel] in
            viewModel.addNewIgnoredTag()
        }

        let doneButton = BlockBarButtonItem(image: .checkmark, style: .plain) { [unowned viewModel] in
            viewModel.saveChanges()
        }

        viewController.navigationItem.rightBarButtonItems = [doneButton, addButton]

        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: showAnimated)
    }
}

// MARK: - IgnoredTagsViewModelDelegate

extension IgnoredTagsCoordinator: IgnoredTagsViewModelDelegate {
    func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
        delegate?.ignoredTagsCoordinatorDidSaveChanges(self)
    }
}
