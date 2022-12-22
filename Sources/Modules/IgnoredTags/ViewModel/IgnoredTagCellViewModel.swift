//
//  IgnoredTagCellViewModel.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import TransientModels

final class IgnoredTagCellViewModel {
    // MARK: - Private properties

    private let tag: IgnoredTag
    private let textChangeSubject = PassthroughSubject<String, Never>()

    // MARK: - Public properties

    var textChange: AnyPublisher<String, Never> {
        return textChangeSubject.eraseToAnyPublisher()
    }

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
        textChangeSubject.send(text)
    }
}
