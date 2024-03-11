//
//  IgnoredTagService.swift
//  MementoFM
//
//  Created by Daniel on 20/08/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - IgnoredTagServiceProtocol

protocol IgnoredTagServiceProtocol: AnyObject {
    var defaultIgnoredTagNames: [String] { get }

    func ignoredTags() -> [IgnoredTag]
    func createDefaultIgnoredTags(withNames names: [String]) -> AnyPublisher<Void, Error>
    func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error>
}

extension IgnoredTagServiceProtocol {
    var defaultIgnoredTagNames: [String] {
        return ["rock", "metal", "indie", "alternative", "seen live", "under 2000 listeners"]
    }

    func createDefaultIgnoredTags() -> AnyPublisher<Void, Error> {
        return createDefaultIgnoredTags(withNames: defaultIgnoredTagNames)
    }
}

// MARK: - IgnoredTagService

final class IgnoredTagService: IgnoredTagServiceProtocol {
    // MARK: - Private properties

    private let ignoredTagStore: IgnoredTagStore

    // MARK: - Init

    init(ignoredTagStore: IgnoredTagStore) {
        self.ignoredTagStore = ignoredTagStore
    }

    // MARK: - Public methods

    func ignoredTags() -> [IgnoredTag] {
        return ignoredTagStore.fetchAll()
    }

    func createDefaultIgnoredTags(withNames names: [String]) -> AnyPublisher<Void, Error> {
        let ignoredTags = names.map { name in
            return IgnoredTag(uuid: UUID().uuidString, name: name)
        }
        return ignoredTagStore.save(ignoredTags: ignoredTags)
    }

    func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error> {
        return ignoredTagStore.overwrite(ignoredTags: ignoredTags)
    }
}
