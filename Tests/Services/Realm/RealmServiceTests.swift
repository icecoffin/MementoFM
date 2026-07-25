//
//  RealmServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 12/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest

@testable import MementoFM
import RealmSwift
import Combine

@MainActor
final class RealmServiceTests: XCTestCase {
    private var realm: Realm!
    private var realmService: RealmService!

    override func setUp() {
        super.setUp()

        realm = RealmFactory.inMemoryRealm()
        realmService = RealmService(
            getRealm: {
                RealmFactory.inMemoryRealm()
            },
            backgroundScheduler: .immediate,
            mainScheduler: .immediate
        )
    }

    override func tearDown() {
        realm = nil
        realmService = nil

        super.tearDown()
    }

    func test_saveSingleObject_writesToRealm() async throws {
        let ignoredTag = IgnoredTag(uuid: "uuid", name: "name")
        _ = try await realmService.save(ignoredTag)

        let expectedIgnoredTag = realm.object(
            ofType: RealmIgnoredTag.self,
            forPrimaryKey: ignoredTag.uuid
        )?.toTransient()
        XCTAssertEqual(expectedIgnoredTag, ignoredTag)
    }

    func test_saveMultipleObjets_writesToRealm() async throws {
        let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                           IgnoredTag(uuid: "uuid2", name: "name2")]
        try await realmService.save(ignoredTags)

        let expectedIgnoredTags = Array(realm.objects(RealmIgnoredTag.self).map({ $0.toTransient() }))
        XCTAssertEqual(expectedIgnoredTags, ignoredTags)

    }

    func test_deleteObjects_deletesFromRealm() async throws {
        let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                           IgnoredTag(uuid: "uuid2", name: "name2")]
        try await realmService.save(ignoredTags)
        let count = realm.objects(RealmIgnoredTag.self).count

        XCTAssertEqual(count, ignoredTags.count)

        try await realmService.deleteObjects(ofType: IgnoredTag.self)

        let expectedCount = realm.objects(RealmIgnoredTag.self).count
        XCTAssertEqual(expectedCount, 0)
    }

    func test_objects_returnsObjectsFromRealm() async throws {
        let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                           IgnoredTag(uuid: "uuid2", name: "name2")]
        _ = try await realmService.save(ignoredTags)

        let expectedIgnoredTags = realmService.objects(IgnoredTag.self)
        XCTAssertEqual(expectedIgnoredTags, ignoredTags)
    }

    func test_objects_returnsObjectsFromRealm_filteredByPredicate() async throws {
        let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                           IgnoredTag(uuid: "uuid2", name: "name2")]
        _ = try await realmService.save(ignoredTags)

        let predicate = NSPredicate(format: "name contains[cd] '1'")
        let expectedIgnoredTags = realmService.objects(IgnoredTag.self, filteredBy: predicate)
        XCTAssertEqual(expectedIgnoredTags, [IgnoredTag(uuid: "uuid1", name: "name1")])
    }

    func test_objectForPrimaryKey_returnsExistingObject() async throws {
        let ignoredTag = IgnoredTag(uuid: "uuid", name: "name")
        _ = try await realmService.save(ignoredTag)

        let expectedIgnoredTag = realmService.object(ofType: IgnoredTag.self, forPrimaryKey: "uuid")
        XCTAssertEqual(expectedIgnoredTag, ignoredTag)
    }

    func test_objectForPrimaryKey_returnsNilForMissingKey() {
        let missingIgnoredTag = realmService.object(ofType: IgnoredTag.self, forPrimaryKey: "test")

        XCTAssertNil(missingIgnoredTag)
    }

    func test_mappedCollection_createsMappedCollectionWithCorrectParameters() {
        let predicate = NSPredicate(format: "name contains[cd] '1'")
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let mappedCollection: AnyPersistentMappedCollection<IgnoredTag>
        mappedCollection = realmService.mappedCollection(filteredUsing: predicate, sortedBy: sortDescriptors)

        XCTAssertEqual(mappedCollection.predicate, predicate)
        XCTAssertEqual(mappedCollection.sortDescriptors, sortDescriptors)
    }
}
