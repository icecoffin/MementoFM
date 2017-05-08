//
//  NetworkOperation.swift
//  LastFMNotifier
//
//  Created by Daniel on 21/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire

class NetworkOperation: AsynchronousOperation {
  private let url: URLConvertible
  private let method: HTTPMethod
  private let parameters: Parameters?
  private let encoding: ParameterEncoding
  private let headers: HTTPHeaders?
  private let completionHandler: (DataResponse<Any>) -> Void

  weak var request: Request?
  var onCancel: (() -> Void)?

  init(url: URLConvertible,
       method: HTTPMethod = .get,
       parameters: Parameters? = nil,
       encoding: ParameterEncoding = URLEncoding.default,
       headers: HTTPHeaders? = nil,
       completionHandler: @escaping (DataResponse<Any>) -> Void) {
    self.url = url
    self.method = method
    self.parameters = parameters
    self.encoding = encoding
    self.headers = headers
    self.completionHandler = completionHandler
    super.init()
  }

  override func main() {
    request = Alamofire.request(url, method: method, parameters: parameters,
                                encoding: encoding, headers: headers).responseJSON { response in
      self.completionHandler(response)
      self.completeOperation()
    }
  }

  override func cancel() {
    onCancel?()
    request?.cancel()
    super.cancel()
  }
}
