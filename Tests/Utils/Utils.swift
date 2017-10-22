//
//  Utils.swift
//  MementoFM
//
//  Created by Daniel on 22/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class Utils {
  static func json(forResource resource: String, withExtension ext: String) -> Any? {
    guard let url = Bundle(for: self).url(forResource: resource, withExtension: ext),
      let data = try? Data(contentsOf: url),
      let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
        return nil
    }

    return jsonObject
  }
}
