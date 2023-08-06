import UIKit
import Core
import SharedServicesInterface
import Sync
import IgnoredTagsInterface
import EnterUsername

public struct SettingsDependencies {
    public let syncCoordinatorFactory: any SyncCoordinatorFactoryProtocol
    public let ignoredTagsCoordinatorFactory: any IgnoredTagsCoordinatorFactoryProtocol
    public let enterUsernameCoordinatorFactory: any EnterUsernameCoordinatorFactoryProtocol

    public init(
        syncCoordinatorFactory: any SyncCoordinatorFactoryProtocol,
        ignoredTagsCoordinatorFactory: any IgnoredTagsCoordinatorFactoryProtocol,
        enterUsernameCoordinatorFactory: any EnterUsernameCoordinatorFactoryProtocol
    ) {
        self.syncCoordinatorFactory = syncCoordinatorFactory
        self.ignoredTagsCoordinatorFactory = ignoredTagsCoordinatorFactory
        self.enterUsernameCoordinatorFactory = enterUsernameCoordinatorFactory
    }
}
