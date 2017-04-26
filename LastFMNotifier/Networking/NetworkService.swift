//
//  NetworkService.swift
//  LastFMNotifier
//
//  Created by Daniel on 05/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire

class NetworkService {
  let baseURL: URL
  let queue = OperationQueue()

  init(baseURL: URL = NetworkConstants.LastFM.baseURL) {
    self.baseURL = baseURL
    queue.maxConcurrentOperationCount = 10
  }

  func cancelPendingRequests() {
    // TODO: deal with "PromiseKit: Pending Promise deallocated! This is usually a bug"
    queue.cancelAllOperations()

    let sessionManager = Alamofire.SessionManager.default
    sessionManager.session.getAllTasks { tasks in
      tasks.forEach({ $0.cancel() })
    }
  }
}
