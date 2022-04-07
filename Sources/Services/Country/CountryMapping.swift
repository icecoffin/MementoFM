//
//  CountryMapping.swift
//  MementoFM
//
//  Created by Dani on 21.12.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation

struct CountryMapping {
    let map: [String: String]
}

extension CountryMapping {
    static func loadFromFile() -> CountryMapping {
        guard let filePath = Bundle.main.path(forResource: "countries", ofType: "json") else {
            fatalError("countries.json is not found")
        }

        let fileURL = URL(fileURLWithPath: filePath)

        do {
            let data = try Data(contentsOf: fileURL)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonObject as? [String: String] else {
                fatalError("Can't read from countries.json")
            }

            return CountryMapping(map: jsonDictionary)
        } catch {
            return CountryMapping(map: [:])
        }
    }

}
