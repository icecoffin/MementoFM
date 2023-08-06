//
//  SettingCellViewModel.swift
//  MementoFM
//
//  Created by Daniel on 23/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

struct SettingConfiguration {
    let title: String
    let action: (() -> Void)
}

final class SettingCellViewModel {
    // MARK: - Private properties

    private let configuration: SettingConfiguration

    // MARK: - Public properties

    var title: String {
        return configuration.title
    }

    // MARK: - Init

    init(configuration: SettingConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Public methods

    func fireAction() {
        configuration.action()
    }
}
