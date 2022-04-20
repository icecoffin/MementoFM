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

class IgnoredTagCellViewModelTests: XCTestCase {

    func test_text_returnsTagName() {
        let tag = IgnoredTag(uuid: "uuid", name: "name")
        let viewModel = IgnoredTagCellViewModel(tag: tag)
        expect(viewModel.text) == tag.name
    }

    func test_tagTextDidChange_callsOnTextChange() {
        let tag = IgnoredTag(uuid: "uuid", name: "name")
        let viewModel = IgnoredTagCellViewModel(tag: tag)

        var updatedText: String = ""
        viewModel.onTextChange = { text in
            updatedText = text
        }
        viewModel.tagTextDidChange("new")
        expect(updatedText) == "new"
    }
}
