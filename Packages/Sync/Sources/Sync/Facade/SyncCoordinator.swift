import UIKit
import Core
import CoreUI

public protocol SyncCoordinatorDelegate: AnyObject {
    func syncCoordinatorDidFinishSync(_ coordinator: SyncCoordinator)
}

public final class SyncCoordinator: Coordinator {
    // MARK: - Private properties

    private let dependencies: SyncDependencies

    // MARK: - Public properties

    public var childCoordinators: [Coordinator] = []
    public var didFinish: (() -> Void)?

    public let navigationController: UINavigationController

    public weak var delegate: SyncCoordinatorDelegate?

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        popTracker: NavigationControllerPopTracker,
        dependencies: SyncDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: - Public methods

    public func start() {
        let viewModel = SyncViewModel(dependencies: dependencies)
        viewModel.delegate = self
        let viewController = SyncViewController(viewModel: viewModel)

        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - SyncViewModelDelegate

extension SyncCoordinator: SyncViewModelDelegate {
    func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel) {
        delegate?.syncCoordinatorDidFinishSync(self)
    }
}
