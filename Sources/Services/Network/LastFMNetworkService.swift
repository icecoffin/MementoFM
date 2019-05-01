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

final class LastFMNetworkService: NetworkService {
  let baseURL: URL
  let queue = OperationQueue()

  init(baseURL: URL = NetworkConstants.LastFM.baseURL) {
    self.baseURL = baseURL
    queue.maxConcurrentOperationCount = 10
  }

  func performRequest<T: Mappable>(method: HTTPMethod,
                                   parameters: Parameters?,
                                   encoding: ParameterEncoding,
                                   headers: HTTPHeaders?) -> Promise<T> {
    return Promise { seal in
      let operation = LastFMNetworkOperation<T>(url: baseURL,
                                                parameters: parameters,
                                                encoding: encoding,
                                                headers: headers) { result in
        switch result {
        case .success(let response):
          seal.fulfill(response)
        case .failure(let error):
          if !error.isCancelled {
            seal.reject(error)
          }
        }
      }
      operation.onCancel = {
        seal.reject(PMKError.cancelled)
      }
      queue.addOperation(operation)
    }
  }

  func cancelPendingRequests() {
    // TODO: PromiseKit: Pending Promise deallocated! This is usually a bug
    queue.cancelAllOperations()
  }
}
