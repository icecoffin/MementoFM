//
//  CountryProvider.swift
//  MementoFM
//
//  Created by Dani on 21.12.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation

protocol CountryProviding {
    func topCountry(for artist: Artist) -> String?
}

final class CountryProvider: CountryProviding {
    private let mapping: CountryMapping

    init(mapping: CountryMapping = .loadFromFile()) {
        self.mapping = mapping
    }

    func topCountry(for artist: Artist) -> String? {
        let country = artist
            .tags
            .compactMap { mapping.map[$0.name] }
            .first
        if country == nil || country?.isEmpty == true {
            log.debug("[DEBUG] \(artist.name): \(artist.tags)")
        }
        return country
    }
}
