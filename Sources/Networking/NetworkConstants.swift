//
//  NetworkConstants.swift
//  MementoFM
//
//  Created by Daniel on 07/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

struct NetworkConstants {
  struct LastFM {
    static var baseURL: URL {
      guard let baseURL = URL(string: "https://ws.audioscrobbler.com/2.0") else {
        fatalError("Can't construct last.fm base URL")
      }
      return baseURL
    }
  }
}
