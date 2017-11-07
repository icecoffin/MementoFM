//
//  NetworkService.swift
//  MementoFM
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import Mapper

protocol NetworkService: class {
  func performRequest<T: Mappable>(method: HTTPMethod,
                                   parameters: Parameters?,
                                   encoding: ParameterEncoding,
                                   headers: HTTPHeaders?) -> Promise<T>
  func cancelPendingRequests()
}

extension NetworkService {
  func performRequest<T: Mappable>(parameters: Parameters?) -> Promise<T> {
    return performRequest(method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
  }
}
