//
//  LibraryPageTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Mapper
import Nimble

class LibraryPageTests: XCTestCase {
    func test_initWithMap_setsCorrectProperties() {
        let libraryPage = makeSampleLibraryPage()

        expect(libraryPage?.index) == 2
        expect(libraryPage?.totalPages) == 720
        expect(libraryPage?.artists.count) == 2
    }

    private func makeSampleLibraryPage() -> LibraryPage? {
        guard let data = Utils.data(fromResource: "sample_library_page", withExtension: "json") else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(LibraryPage.self, from: data)
    }
}
