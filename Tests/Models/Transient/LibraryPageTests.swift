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
        guard let json = Utils.json(forResource: "sample_library_page", withExtension: "json") as? NSDictionary else {
            return nil
        }

        let mapper = Mapper(JSON: json)
        return try? LibraryPage(map: mapper)
    }
}
