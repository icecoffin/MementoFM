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
  private func sampleLibraryPage() -> LibraryPage? {
    guard let json = Utils.json(forResource: "sample_library_page", withExtension: "json") as? NSDictionary else {
      return nil
    }

    let mapper = Mapper(JSON: json)
    return try? LibraryPage(map: mapper)
  }

  func testInitializingWithMapper() {
    let libraryPage = sampleLibraryPage()
    expect(libraryPage?.index).to(equal(2))
    expect(libraryPage?.totalPages).to(equal(720))
    expect(libraryPage?.artists.count).to(equal(2))
  }
}
