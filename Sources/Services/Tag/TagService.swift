//
//  TagService.swift
//  MementoFM
//
//  Created by Daniel on 10/08/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: - TagServiceProtocol

protocol TagServiceProtocol: AnyObject {
    func getTopTags(for artists: [Artist], progress: ((TopTagsRequestProgress) -> Promise<Void>)?) -> Promise<Void>
    func getAllTopTags() -> [Tag]
}

extension TagServiceProtocol {
    func getTopTags(for artists: [Artist]) -> Promise<Void> {
        return getTopTags(for: artists, progress: nil)
    }
}

// MARK: - TagService

final class TagService: TagServiceProtocol {
    // MARK: - Private properties

    private let persistentStore: PersistentStore
    private let repository: TagRepository

    // MARK: - Init

    init(persistentStore: PersistentStore, repository: TagRepository) {
        self.persistentStore = persistentStore
        self.repository = repository
    }

    // MARK: - Public methods

    func getTopTags(for artists: [Artist], progress: ((TopTagsRequestProgress) -> Promise<Void>)?) -> Promise<Void> {
        return Promise { seal in
            let totalProgress = Progress(totalUnitCount: Int64(artists.count))

            let promises = artists.map { artist in
                return repository.getTopTags(for: artist.name).compactMap { topTagsResponse -> Promise<Void>? in
                    totalProgress.completedUnitCount += 1
                    let topTagsList = topTagsResponse.topTagsList
                    return progress?(TopTagsRequestProgress(progress: totalProgress, artist: artist, topTagsList: topTagsList))
                }
            }

            when(fulfilled: promises).done { _ in
                seal.fulfill(())
            }.catch { error in
                if !error.isCancelled {
                    seal.reject(error)
                }
            }
        }
    }

    func getAllTopTags() -> [Tag] {
        let artists = self.persistentStore.objects(Artist.self)
        return artists.flatMap { return $0.topTags }
    }
}
