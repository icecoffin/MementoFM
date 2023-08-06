//
//  NetworkService.swift
//  MementoFM
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

public protocol NetworkService: AnyObject {
    func performRequest<T: Codable>(
        method: HTTPMethod,
        parameters: [String: Any]?,
        encoding: ParameterEncoding,
        headers: [String: String]?
    ) -> AnyPublisher<T, Error>
}

extension NetworkService {
    public func performRequest<T: Codable>(parameters: [String: Any]?) -> AnyPublisher<T, Error> {
        return performRequest(
            method: .get,
            parameters: parameters,
            encoding: .url,
            headers: nil
        )
    }
}
