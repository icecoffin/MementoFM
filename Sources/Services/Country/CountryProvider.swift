//
//  CountryProvider.swift
//  MementoFM
//
//  Created by Dani on 21.12.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
import TransientModels

// MARK: - CountryProviding

protocol CountryProviding {
    func topCountry(for artist: Artist) -> String?
}

// MARK: - CountryProvider

final class CountryProvider: CountryProviding {
    // MARK: - Private properties

    private let mapping: CountryMapping

    // MARK: - Init

    init(mapping: CountryMapping = .loadFromFile()) {
        self.mapping = mapping
    }

    // MARK: - Public methods

    func topCountry(for artist: Artist) -> String? {
        return artist
            .tags
            .compactMap { mapping.map[$0.name] }
            .first
    }
}
