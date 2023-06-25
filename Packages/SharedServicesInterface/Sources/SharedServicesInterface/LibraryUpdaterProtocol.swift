import Foundation
import Combine
import TransientModels

// MARK: - LibraryUpdateStatus

public enum LibraryUpdateStatus {
    case artistsFirstPage
    case artists(progress: PageProgress)
    case recentTracksFirstPage
    case recentTracks(progress: PageProgress)
    case tags(artistName: String, progress: PageProgress)
}

// MARK: - LibraryUpdaterProtocol

public protocol LibraryUpdaterProtocol: AnyObject {
    var isLoading: AnyPublisher<Bool, Never> { get }
    var status: AnyPublisher<LibraryUpdateStatus, Never> { get }
    var error: AnyPublisher<Error, Never> { get }

    var isFirstUpdate: Bool { get }
    var lastUpdateTimestamp: TimeInterval { get }

    func requestData()
    func cancelPendingRequests()
}
