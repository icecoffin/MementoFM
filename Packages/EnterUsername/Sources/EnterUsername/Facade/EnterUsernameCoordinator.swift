import UIKit
import CoreUI

// MARK: - EnterUsernameCoordinatorDelegate

public protocol EnterUsernameCoordinatorDelegate: AnyObject {
    func enterUsernameCoordinatorDidFinish(_ coordinator: EnterUsernameCoordinator)
}

// MARK: - EnterUsernameCoordinator

public final class EnterUsernameCoordinator: NavigationFlowCoordinator {
    public struct Configuration {
        public let title: String
        public let showsBackButtonTitle: Bool
        public let forwardButtonAction: (() -> Void)?

        public init(title: String, showsBackButtonTitle: Bool, forwardButtonAction: (() -> Void)? = nil) {
            self.title = title
            self.showsBackButtonTitle = showsBackButtonTitle
            self.forwardButtonAction = forwardButtonAction
        }
    }

    // MARK: - Private properties

    private let dependencies: EnterUsernameDependencies
    private let configuration: Configuration

    // MARK: - Public properties

    public let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []
    public var didFinish: (() -> Void)?

    public weak var delegate: EnterUsernameCoordinatorDelegate?

    // MARK: - Init

    init(
        dependencies: EnterUsernameDependencies,
        navigationController: UINavigationController,
        configuration: Configuration
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
        self.configuration = configuration
    }

    // MARK: - Public methods

    public func start() {
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)
        viewModel.delegate = self
        let viewController = EnterUsernameViewController(viewModel: viewModel)
        if !configuration.showsBackButtonTitle {
            viewController.navigationItem.backButtonDisplayMode = .minimal
        }
        viewController.title = configuration.title
        if let forwardButtonAction = configuration.forwardButtonAction {
            let forwardButton = BlockBarButtonItem(image: .arrowRight, style: .plain) {
                forwardButtonAction()
            }
            viewController.navigationItem.rightBarButtonItem = forwardButton
        }
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - EnterUsernameViewModelDelegate

extension EnterUsernameCoordinator: EnterUsernameViewModelDelegate {
    func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
        delegate?.enterUsernameCoordinatorDidFinish(self)
    }
}
