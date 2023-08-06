import UIKit
import Combine
import Core
import TransientModels
import SharedServicesInterface
import Sync
import IgnoredTagsInterface
import EnterUsername

public struct OnboardingDependencies: HasArtistService, HasUserService, HasIgnoredTagService {
    public let artistService: ArtistServiceProtocol
    public let userService: UserServiceProtocol
    public let ignoredTagService: IgnoredTagServiceProtocol
    public let syncCoordinatorFactory: any SyncCoordinatorFactoryProtocol
    public let ignoredTagsCoordinatorFactory: any IgnoredTagsCoordinatorFactoryProtocol
    public let enterUsernameCoordinatorFactory: any EnterUsernameCoordinatorFactoryProtocol

    public init(
        artistService: ArtistServiceProtocol,
        userService: UserServiceProtocol,
        ignoredTagService: IgnoredTagServiceProtocol,
        syncCoordinatorFactory: any SyncCoordinatorFactoryProtocol,
        ignoredTagsCoordinatorFactory: any IgnoredTagsCoordinatorFactoryProtocol,
        enterUsernameCoordinatorFactory: any EnterUsernameCoordinatorFactoryProtocol
    ) {
        self.artistService = artistService
        self.userService = userService
        self.ignoredTagService = ignoredTagService
        self.syncCoordinatorFactory = syncCoordinatorFactory
        self.ignoredTagsCoordinatorFactory = ignoredTagsCoordinatorFactory
        self.enterUsernameCoordinatorFactory = enterUsernameCoordinatorFactory
    }
}
