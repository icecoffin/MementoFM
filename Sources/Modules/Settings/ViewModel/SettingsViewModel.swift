//
//  SettingsViewModel.swift
//  MementoFM
//
//  Created by Daniel on 16/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

protocol SettingsViewModelDelegate: class {
    func settingsViewModelDidRequestOpenIgnoredTags(_ viewModel: SettingsViewModel)
    func settingsViewModelDidRequestChangeUser(_ viewModel: SettingsViewModel)
    func settingsViewModelDidRequestOpenAbout(_ viewModel: SettingsViewModel)
}

final class SettingsViewModel {
    private lazy var cellViewModels: [SettingCellViewModel] = self.createCellViewModels()
    weak var delegate: SettingsViewModelDelegate?

    var itemCount: Int {
        return cellViewModels.count
    }

    private func createCellViewModels() -> [SettingCellViewModel] {
        let ignoredTagsConfiguration = SettingConfiguration(title: "Ignored tags".unlocalized) { [unowned self] in
            self.delegate?.settingsViewModelDidRequestOpenIgnoredTags(self)
        }

        let changeUserConfiguration = SettingConfiguration(title: "Change user".unlocalized) { [unowned self] in
            self.delegate?.settingsViewModelDidRequestChangeUser(self)
        }

        let aboutConfiguration = SettingConfiguration(title: "About".unlocalized) { [unowned self] in
            self.delegate?.settingsViewModelDidRequestOpenAbout(self)
        }

        return [SettingCellViewModel(configuration: ignoredTagsConfiguration),
                SettingCellViewModel(configuration: changeUserConfiguration),
                SettingCellViewModel(configuration: aboutConfiguration)]
    }

    func cellViewModel(at index: Int) -> SettingCellViewModel {
        return cellViewModels[index]
    }

    func handleTap(at index: Int) {
        cellViewModels[index].fireAction()
    }
}
