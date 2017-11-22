//
//  IgnoredTagCellViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 21/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import PromiseKit

class IgnoredTagCellViewModelTests: XCTestCase {
  func testGettingText() {
    let tag = IgnoredTag(uuid: "uuid", name: "name")
    let viewModel = IgnoredTagCellViewModel(tag: tag)
    expect(viewModel.text).to(equal(tag.name))
  }

  func testCallingTextDidChange() {
    let tag = IgnoredTag(uuid: "uuid", name: "name")
    let viewModel = IgnoredTagCellViewModel(tag: tag)

    var updatedText: String = ""
    viewModel.onTextChange = { text in
      updatedText = text
    }
    viewModel.tagTextDidChange("new")
    expect(updatedText).toEventually(equal("new"))
  }
}
