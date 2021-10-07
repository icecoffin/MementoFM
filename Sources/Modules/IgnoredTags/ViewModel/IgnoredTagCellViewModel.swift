//
//  IgnoredTagCellViewModel.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

final class IgnoredTagCellViewModel {
    // MARK: - Private properties

    private let tag: IgnoredTag

    // MARK: - Public properties

    var onTextChange: ((String) -> Void)?

    var placeholder: String {
        return "Enter tag here".unlocalized
    }

    var text: String {
        return tag.name
    }

    // MARK: - Init

    init(tag: IgnoredTag) {
        self.tag = tag
    }

    // MARK: - Public methods

    func tagTextDidChange(_ text: String) {
        onTextChange?(text)
    }
}
