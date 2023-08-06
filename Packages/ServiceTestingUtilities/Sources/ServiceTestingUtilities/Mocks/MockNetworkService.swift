//
//  MockNetworkService.swift
//  MementoFM
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import NetworkingInterface

final class MockNetworkService: NetworkService {
    struct PerformRequestParameters {
        let method: HTTPMethod
        let parameters: [String: Any]?
        let encoding: ParameterEncoding
        let headers: [String: String]?
    }

    var performRequestParameters: PerformRequestParameters?
    var customResponse: Any?
    func performRequest<T: Codable>(
        method: HTTPMethod,
        parameters: [String: Any]?,
        encoding: ParameterEncoding,
        headers: [String: String]?
    ) -> AnyPublisher<T, Error> {
        performRequestParameters = PerformRequestParameters(
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        )

        guard let response = customResponse as? T else {
            fatalError("Response type should be the same as performRequest response type")
        }

        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
