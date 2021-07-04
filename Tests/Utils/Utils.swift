//
//  Utils.swift
//  MementoFM
//
//  Created by Daniel on 22/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class Utils {
    static func data(fromResource resource: String, withExtension ext: String) -> Data? {
        guard let url = Bundle(for: self).url(forResource: resource, withExtension: ext),
              let data = try? Data(contentsOf: url) else {
            return nil
        }

        return data
    }
}
