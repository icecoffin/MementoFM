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
import Combine

protocol NetworkService: AnyObject {
    func performRequest<T: Codable>(method: HTTPMethod,
                                    parameters: Parameters?,
                                    encoding: ParameterEncoding,
                                    headers: HTTPHeaders?) -> Promise<T>
    func performRequest<T: Codable>(method: HTTPMethod,
                                    parameters: Parameters?,
                                    encoding: ParameterEncoding,
                                    headers: HTTPHeaders?) -> AnyPublisher<T, Error>
    func cancelPendingRequests()
}

extension NetworkService {
    func performRequest<T: Codable>(parameters: Parameters?) -> Promise<T> {
        return performRequest(method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
    }

    func performRequest<T: Codable>(parameters: Parameters?) -> AnyPublisher<T, Error> {
        return performRequest(method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
    }

}
