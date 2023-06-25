import Foundation
import Combine
import TransientModels

// MARK: - TopTagsPage

public struct TopTagsPage {
    public let artist: Artist
    public let topTagsList: TopTagsList

    public init(artist: Artist, topTagsList: TopTagsList) {
        self.artist = artist
        self.topTagsList = topTagsList
    }
}

// MARK: - TagServiceProtocol

public protocol TagServiceProtocol: AnyObject {
    func getTopTags(for artists: [Artist]) -> AnyPublisher<TopTagsPage, Error>
    func getAllTopTags() -> [Tag]
}
