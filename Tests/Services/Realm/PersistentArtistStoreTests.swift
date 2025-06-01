import Foundation
import XCTest
@testable import MementoFM

final class PersistentArtistStoreTests: XCTestCase {
    private var persistentStore: MockPersistentStore!
    private var artistStore: PersistentArtistStore!

    override func setUp() {
        super.setUp()

        persistentStore = MockPersistentStore()
        artistStore = PersistentArtistStore(persistentStore: persistentStore)
    }

    override func tearDown() {
        persistentStore = nil
        artistStore = nil

        super.tearDown()
    }

    func test_artistForID_readsFromPersistentStore() {
        let artist = ModelFactory.generateArtist()
        persistentStore.customObjectForKey = artist

        let fetchedArtist = artistStore.artist(for: "id")

        XCTAssertEqual(persistentStore.objectPrimaryKeys, ["id"])
        XCTAssertEqual(artist, fetchedArtist)
    }

    func test_deleteAll_deletesFromPersistentStore() {
        _ = artistStore.deleteAll()

        XCTAssertTrue(persistentStore.didCallDelete)
        XCTAssertEqual(persistentStore.deletedObjectsTypeNames, ["Artist"])
    }

    func test_fetchAll_readsFromPersistentStore() {
        let artists = ModelFactory.generateArtists(inAmount: 5)
        persistentStore.customObjects = artists

        let predicate = NSPredicate(format: "name == \"test\"")
        let fetchedArtists = artistStore.fetchAll(filteredBy: predicate)

        XCTAssertEqual(persistentStore.objectsPredicate?.predicateFormat, predicate.predicateFormat)
        XCTAssertEqual(fetchedArtists, artists)
    }

    func test_saveArtists_writesToPersistentStore() {
        let artists = ModelFactory.generateArtists(inAmount: 5)

        _ = artistStore.save(artists: artists)

        XCTAssertEqual(persistentStore.saveParameters?.objects as? [Artist], artists)
        XCTAssertEqual(persistentStore.saveParameters?.update, true)
    }
}
