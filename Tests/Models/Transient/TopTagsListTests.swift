//
//  TopTagsListTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Mapper
import Nimble

class TopTagsListTests: XCTestCase {
  private func sampleTopTagsList() -> TopTagsList? {
    guard let json = Utils.json(forResource: "sample_top_tags_list", withExtension: "json") as? NSDictionary else {
      return nil
    }

    let mapper = Mapper(JSON: json)
    return try? TopTagsList(map: mapper)
  }

  func testInitializingWithMapper() {
    let topTagsList = sampleTopTagsList()
    expect(topTagsList?.tags.count).to(equal(TopTagsList.maxTagCount))
  }
}
