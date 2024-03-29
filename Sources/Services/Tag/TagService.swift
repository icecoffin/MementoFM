//
//  TagService.swift
//  MementoFM
//
//  Created by Daniel on 10/08/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - TopTagsPage

struct TopTagsPage {
    let artist: Artist
    let topTagsList: TopTagsList
}

// MARK: - TagServiceProtocol

protocol TagServiceProtocol: AnyObject {
    func getTopTags(for artists: [Artist]) -> AnyPublisher<TopTagsPage, Error>
    func getAllTopTags() -> [Tag]
}

// MARK: - TagService

final class TagService: TagServiceProtocol {
    // MARK: - Private properties

    private let artistStore: ArtistStore
    private let repository: TagRepository

    // MARK: - Init

    init(artistStore: ArtistStore, repository: TagRepository) {
        self.artistStore = artistStore
        self.repository = repository
    }

    // MARK: - Public methods

    func getTopTags(for artists: [Artist]) -> AnyPublisher<TopTagsPage, Error> {
        let publishers = artists.map { artist -> AnyPublisher<TopTagsPage, Error> in
            return repository.getTopTags(for: artist.name)
                .map { TopTagsPage(artist: artist, topTagsList: $0.topTagsList) }
                .eraseToAnyPublisher()
        }

        return Publishers.Sequence(sequence: publishers)
            .flatMap(maxPublishers: .max(5)) { $0 }
            .eraseToAnyPublisher()
    }

    func getAllTopTags() -> [Tag] {
        let artists = artistStore.fetchAll()
        return artists.flatMap { return $0.topTags }
    }
}
