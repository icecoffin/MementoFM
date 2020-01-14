//
//  TagCellViewModel.swift
//  MementoFM
//
//  Created by Daniel on 14/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

final class TagCellViewModel {
    private let tag: Tag

    init(tag: Tag) {
        self.tag = tag
    }

    var name: String {
        return tag.name
    }
}
