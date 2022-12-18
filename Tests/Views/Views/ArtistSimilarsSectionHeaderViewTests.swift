//
//  ArtistSimilarsSectionHeaderViewTests.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import SnapshotTesting
@testable import MementoFM

final class ArtistSimilarsSectionHeaderViewTests: XCTestCase {
    func test_looksCorrect() {
        let view: ArtistSimilarsSectionHeaderView = makeAndSizeToFit(width: 375) { view in
            let viewModel = MockArtistSimilarsSectionHeaderViewModel()
            view.configure(with: viewModel)
        }

        assertSnapshots(matching: view)
    }
}

private final class MockArtistSimilarsSectionHeaderViewModel: ArtistSectionHeaderViewModelProtocol {
    let sectionHeaderText: String? = "Test text"
}
