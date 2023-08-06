import Foundation
import SharedServicesInterface

public struct SyncDependencies: HasLibraryUpdater {
    public let libraryUpdater: LibraryUpdaterProtocol

    public init(
        libraryUpdater: LibraryUpdaterProtocol
    ) {
        self.libraryUpdater = libraryUpdater
    }
}
