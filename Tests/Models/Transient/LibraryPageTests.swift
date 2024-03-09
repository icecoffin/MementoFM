//
//  LibraryPageTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

final class LibraryPageTests: XCTestCase {
    func test_decodeFromJSON_setsCorrectProperties() {
        let libraryPage = makeSampleLibraryPage()

        XCTAssertEqual(libraryPage?.index, 2)
        XCTAssertEqual(libraryPage?.totalPages, 720)
        XCTAssertEqual(libraryPage?.artists.count, 2)
    }

    // MARK: - Helpers

    private func makeSampleLibraryPage() -> LibraryPage? {
        guard let data = Utils.data(fromResource: "sample_library_page", withExtension: "json") else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(LibraryPage.self, from: data)
    }
}
