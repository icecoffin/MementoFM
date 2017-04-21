//
//  NetworkService.swift
//  LastFMNotifier
//
//  Created by Daniel on 05/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class NetworkService {
  let baseURL: URL
  let queue = OperationQueue()

  init(baseURL: URL = NetworkConstants.LastFM.baseURL) {
    self.baseURL = baseURL
    queue.maxConcurrentOperationCount = 10
  }
}
