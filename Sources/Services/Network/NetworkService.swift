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

protocol NetworkService: AnyObject {
    func performRequest<T: Codable>(method: HTTPMethod,
                                    parameters: Parameters?,
                                    encoding: ParameterEncoding,
                                    headers: HTTPHeaders?) -> Promise<T>
    func cancelPendingRequests()
}

extension NetworkService {
    func performRequest<T: Codable>(parameters: Parameters?) -> Promise<T> {
        return performRequest(method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
    }
}
