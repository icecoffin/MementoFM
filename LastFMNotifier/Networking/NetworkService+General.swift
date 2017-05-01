//
//  NetworkService+General.swift
//  LastFMNotifier
//
//  Created by Daniel on 29/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire

protocol GeneralNetworkService {
  func cancelPendingRequests()
}

extension NetworkService: GeneralNetworkService {
  func cancelPendingRequests() {
    // TODO: deal with "PromiseKit: Pending Promise deallocated! This is usually a bug"
    queue.cancelAllOperations()

    let sessionManager = Alamofire.SessionManager.default
    sessionManager.session.getAllTasks { tasks in
      tasks.forEach({ $0.cancel() })
    }
  }
}
