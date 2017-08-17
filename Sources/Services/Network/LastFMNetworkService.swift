//
//  LastFMNetworkService.swift
//  MementoFM
//
//  Created by Daniel on 27/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import Mapper

class LastFMNetworkService {
  let baseURL: URL
  let queue = OperationQueue()

  init(baseURL: URL = NetworkConstants.LastFM.baseURL) {
    self.baseURL = baseURL
    queue.maxConcurrentOperationCount = 10
  }

  func performRequest<T: Mappable>(method: HTTPMethod = .get,
                                   parameters: Parameters? = nil,
                                   encoding: ParameterEncoding = URLEncoding.default,
                                   headers: HTTPHeaders? = nil) -> Promise<T> {
    return Promise { fulfill, reject in
      let operation = LastFMNetworkOperation<T>(url: baseURL, parameters: parameters) { result in
        switch result {
        case .success(let response):
          fulfill(response)
        case .failure(let error):
          if !error.isCancelledError {
            reject(error)
          }
        }
      }
      operation.onCancel = {
        reject(NSError.cancelledError())
      }
      queue.addOperation(operation)
    }
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