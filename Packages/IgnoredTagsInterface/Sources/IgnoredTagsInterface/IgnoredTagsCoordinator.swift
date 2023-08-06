import UIKit
import Core
import CoreUI

// MARK: - IgnoredTagsCoordinatorDelegate

public protocol IgnoredTagsCoordinatorDelegate: AnyObject {
    func ignoredTagsCoordinatorDidSaveChanges(_ coordinator: any IgnoredTagsCoordinatorProtocol)
}

public protocol IgnoredTagsCoordinatorProtocol: NavigationFlowCoordinator {
    var delegate: IgnoredTagsCoordinatorDelegate? { get set }
}
