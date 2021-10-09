//
//  IgnoredTagService.swift
//  MementoFM
//
//  Created by Daniel on 20/08/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: - IgnoredTagServiceProtocol

protocol IgnoredTagServiceProtocol: AnyObject {
    var defaultIgnoredTagNames: [String] { get }

    func ignoredTags() -> [IgnoredTag]
    func createDefaultIgnoredTags(withNames names: [String]) -> Promise<Void>
    func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> Promise<Void>
}

extension IgnoredTagServiceProtocol {
    var defaultIgnoredTagNames: [String] {
        return ["rock", "metal", "indie", "alternative", "seen live", "under 2000 listeners"]
    }

    func createDefaultIgnoredTags() -> Promise<Void> {
        return createDefaultIgnoredTags(withNames: defaultIgnoredTagNames)
    }
}

// MARK: - IgnoredTagService

final class IgnoredTagService: IgnoredTagServiceProtocol {
    // MARK: - Private properties

    private let persistentStore: PersistentStore

    // MARK: - Init

    init(persistentStore: PersistentStore) {
        self.persistentStore = persistentStore
    }

    // MARK: - Public methods

    func ignoredTags() -> [IgnoredTag] {
        return persistentStore.objects(IgnoredTag.self)
    }

    func createDefaultIgnoredTags(withNames names: [String]) -> Promise<Void> {
        let ignoredTags = names.map { name in
            return IgnoredTag(uuid: UUID().uuidString, name: name)
        }
        return persistentStore.save(ignoredTags)
    }

    func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> Promise<Void> {
        return persistentStore.deleteObjects(ofType: IgnoredTag.self).then {
            return self.persistentStore.save(ignoredTags)
        }
    }
}
