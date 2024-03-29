//
//  IgnoredTagCellViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 21/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest

import Combine
@testable import MementoFM

final class IgnoredTagCellViewModelTests: XCTestCase {
    private var cancelBag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        cancelBag = .init()
    }

    override func tearDown() {
        cancelBag = nil

        super.tearDown()
    }

    func test_text_returnsTagName() {
        let tag = IgnoredTag(uuid: "uuid", name: "name")
        let viewModel = IgnoredTagCellViewModel(tag: tag)
        XCTAssertEqual(viewModel.text, tag.name)
    }

    func test_tagTextDidChange_callsOnTextChange() {
        let tag = IgnoredTag(uuid: "uuid", name: "name")
        let viewModel = IgnoredTagCellViewModel(tag: tag)

        var updatedText: String = ""
        viewModel.textChange
            .sink(receiveValue: { text in
                updatedText = text
            })
            .store(in: &cancelBag)

        viewModel.tagTextDidChange("new")

        XCTAssertEqual(updatedText, "new")
    }
}
