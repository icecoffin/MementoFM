//
//  TagCellViewModel.swift
//  MementoFM
//
//  Created by Daniel on 14/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

final class TagCellViewModel {
    // MARK: - Private properties

    private let tag: Tag

    // MARK: - Public properties

    var name: String {
        return tag.name
    }

    // MARK: - Init

    init(tag: Tag) {
        self.tag = tag
    }
}
