//
//  TagCellViewModel.swift
//  MementoFM
//
//  Created by Daniel on 14/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import TransientModels

final class TagCellViewModel {
    // MARK: - Private properties

    private let tag: Tag
    private let showCount: Bool

    // MARK: - Public properties

    var name: String {
        return tag.name
    }

    var text: String {
        if showCount {
            return "\(name) (\(tag.count))"
        } else {
            return name
        }
    }

    // MARK: - Init

    init(tag: Tag, showCount: Bool) {
        self.tag = tag
        self.showCount = showCount
    }
}
