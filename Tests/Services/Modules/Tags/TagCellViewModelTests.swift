//
//  TagCellViewModelTests.swift
//  MementoFMTests
//
//  Created by Dani on 09.04.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import Nimble
@testable import MementoFM

final class TagCellViewModelTests: XCTestCase {
    func test_name_returnsTagName() {
        let viewModel = TagCellViewModel(tag: makeTag(), showCount: false)

        expect(viewModel.name) == "test tag"
    }

    func test_text_returnsTagNameWithCount() {
        let viewModel = TagCellViewModel(tag: makeTag(), showCount: true)

        expect(viewModel.text) == "test tag (15)"
    }

    func test_text_returnsTagNameWhenNotShowingCount() {
        let viewModel = TagCellViewModel(tag: makeTag(), showCount: false)

        expect(viewModel.text) == "test tag"
    }

    private func makeTag() -> Tag {
        return Tag(name: "test tag", count: 15)
    }
}
