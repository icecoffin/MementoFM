//
//  MappingHelpers.swift
//  LastFMNotifier
//
//  Created by Daniel on 31/03/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

func int(from anyString: Any, defaultValue: Int = 0) -> Int {
  if let stringValue = anyString as? String {
    return Int(stringValue) ?? defaultValue
  } else {
    return defaultValue
  }
}
