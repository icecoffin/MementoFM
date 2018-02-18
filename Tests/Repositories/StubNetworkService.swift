//
//  StubNetworkService.swift
//  MementoFM
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit
import Mapper

class StubNetworkService<ResponseType>: NetworkService where ResponseType: Mappable {
  var method: HTTPMethod?
  var parameters: Parameters?
  var encoding: ParameterEncoding?
  var headers: HTTPHeaders?

  let response: ResponseType

  init(response: ResponseType) {
    self.response = response
  }

  func performRequest<T>(method: HTTPMethod,
                         parameters: Parameters?,
                         encoding: ParameterEncoding,
                         headers: HTTPHeaders?) -> Promise<T> where T: Mappable {
    self.method = method
    self.parameters = parameters
    self.encoding = encoding
    self.headers = headers
    guard let response = response as? T else {
      fatalError("ResponseType should be the same as performRequest response type")
    }
    return .value(response)
  }

  var didCancelPendingRequests = false
  func cancelPendingRequests() {
    didCancelPendingRequests = true
  }
}
