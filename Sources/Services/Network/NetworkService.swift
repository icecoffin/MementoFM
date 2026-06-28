//
//  NetworkService.swift
//  MementoFM
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire
import Combine

protocol NetworkService: AnyObject {
    func performRequest<T: Codable>(
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?
    ) async throws -> T
}

extension NetworkService {
    func performRequest<T: Codable>(parameters: Parameters?) async throws -> T {
        return try await performRequest(
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: nil
        )
    }
}
