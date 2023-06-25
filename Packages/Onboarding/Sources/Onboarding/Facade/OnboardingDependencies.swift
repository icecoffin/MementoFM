import Foundation
import UIKit
import Combine
import Core
import TransientModels
import Sync
import SharedServicesInterface

public struct OnboardingDependencies: HasArtistService, HasUserService, HasIgnoredTagService {
    public let artistService: ArtistServiceProtocol
    public let userService: UserServiceProtocol
    public let ignoredTagService: IgnoredTagServiceProtocol
    public let syncCoordinatorFactory: ((UINavigationController, NavigationControllerPopTracker) -> SyncCoordinator)

    public init(
        artistService: ArtistServiceProtocol,
        userService: UserServiceProtocol,
        ignoredTagService: IgnoredTagServiceProtocol,
        syncCoordinatorFactory: @escaping ((UINavigationController, NavigationControllerPopTracker) -> SyncCoordinator)
    ) {
        self.artistService = artistService
        self.userService = userService
        self.ignoredTagService = ignoredTagService
        self.syncCoordinatorFactory = syncCoordinatorFactory
    }
}
