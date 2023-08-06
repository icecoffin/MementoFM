//
//  RealmServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 12/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
import Nimble
import RealmSwift
import Combine
import TransientModels
import Persistence
import PersistenceInterface
import InfrastructureTestingUtilities

final class RealmServiceTests: XCTestCase {
    private var realm: Realm!
    private var realmService: RealmService!

    override func setUp() {
        super.setUp()

        realm = RealmFactory.inMemoryRealm()
        realmService = RealmService(getRealm: {
            return RealmFactory.inMemoryRealm()
        }, backgroundScheduler: .immediate, mainScheduler: .immediate)
    }

    override func tearDown() {
        realm = nil
        realmService = nil

        super.tearDown()
    }

    func test_saveSingleObject_writesToRealm() {
        let ignoredTag = IgnoredTag(uuid: "uuid", name: "name")
        _ = realmService.save(ignoredTag).sink(receiveCompletion: { _ in
            let expectedIgnoredTag = self.realm.object(ofType: RealmIgnoredTag.self,
                                                       forPrimaryKey: ignoredTag.uuid)?.toTransient()
            expect(expectedIgnoredTag) == ignoredTag
        }, receiveValue: { _ in })
    }

    func test_saveMultipleObjets_writesToRealm() {
        let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                           IgnoredTag(uuid: "uuid2", name: "name2")]
        _ = realmService.save(ignoredTags).sink(receiveCompletion: { _ in
            let expectedIgnoredTags = Array(self.realm.objects(RealmIgnoredTag.self).map({ $0.toTransient() }))
            expect(expectedIgnoredTags) == ignoredTags
        }, receiveValue: { _ in })
    }

    func test_deleteObjects_deletesFromRealm() {
        let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                           IgnoredTag(uuid: "uuid2", name: "name2")]
        _ = realmService.save(ignoredTags).flatMap { _ -> AnyPublisher<Void, Error> in
            let count = self.realm.objects(RealmIgnoredTag.self).count
            expect(count).to(equal(ignoredTags.count))
            return self.realmService.deleteObjects(ofType: IgnoredTag.self)
        }.sink(receiveCompletion: { _ in
            let expectedCount = self.realm.objects(RealmIgnoredTag.self).count
            expect(expectedCount) == 0
        }, receiveValue: { _ in })
    }

    func test_objects_returnsObjectsFromRealm() {
        let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                           IgnoredTag(uuid: "uuid2", name: "name2")]
        _ = realmService.save(ignoredTags).sink(receiveCompletion: { _ in
            let expectedIgnoredTags = self.realmService.objects(IgnoredTag.self)
            expect(expectedIgnoredTags) == ignoredTags
        }, receiveValue: { _ in })
    }

    func test_objects_returnsObjectsFromRealm_filteredByPredicate() {
        let ignoredTags = [IgnoredTag(uuid: "uuid1", name: "name1"),
                           IgnoredTag(uuid: "uuid2", name: "name2")]
        _ = realmService.save(ignoredTags).sink(receiveCompletion: { _ in
            let predicate = NSPredicate(format: "name contains[cd] '1'")
            let expectedIgnoredTags = self.realmService.objects(IgnoredTag.self, filteredBy: predicate)
            expect(expectedIgnoredTags) == [IgnoredTag(uuid: "uuid1", name: "name1")]
        }, receiveValue: { _ in })
    }

    func test_objectForPrimaryKey_returnsExistingObject() {
        let ignoredTag = IgnoredTag(uuid: "uuid", name: "name")
        _ = realmService.save(ignoredTag).sink(receiveCompletion: { _ in
            let expectedIgnoredTag = self.realmService.object(ofType: IgnoredTag.self, forPrimaryKey: "uuid")
            expect(expectedIgnoredTag) == ignoredTag
        }, receiveValue: { _ in })
    }

    func test_objectForPrimaryKey_returnsNilForMissingKey() {
        let missingIgnoredTag = self.realmService.object(ofType: IgnoredTag.self, forPrimaryKey: "test")

        expect(missingIgnoredTag).to(beNil())
    }

    func test_mappedCollection_createsMappedCollectionWithCorrectParameters() {
        let predicate = NSPredicate(format: "name contains[cd] '1'")
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let mappedCollection: AnyPersistentMappedCollection<IgnoredTag>
        mappedCollection = realmService.mappedCollection(filteredUsing: predicate, sortedBy: sortDescriptors)

        expect(mappedCollection.predicate) == predicate
        expect(mappedCollection.sortDescriptors) == sortDescriptors
    }
}
