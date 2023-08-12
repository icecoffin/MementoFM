//
//  ArtistTopTagsSectionHeaderViewTests.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import SnapshotTesting
import InfrastructureTestingUtilities
@testable import MementoFM

final class ArtistTopTagsSectionHeaderViewTests: XCTestCase {
    func test_looksCorrect() {
        let view: ArtistTopTagsSectionHeaderView = makeAndSizeToFit(width: 375) { view in
            let viewModel = MockArtistTopTagsSectionHeaderViewModel()
            view.configure(with: viewModel)
        }

        assertSnapshots(matching: view)
    }
}

private final class MockArtistTopTagsSectionHeaderViewModel: ArtistSectionHeaderViewModelProtocol {
    let sectionHeaderText: String? = "Test text"
}
