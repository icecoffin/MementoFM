//
//  MockNetworkService.swift
//  MementoFM
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Alamofire
import Combine

final class MockNetworkService: NetworkService {
    struct PerformRequestParameters {
        let method: HTTPMethod
        let parameters: Parameters?
        let encoding: ParameterEncoding?
        let headers: HTTPHeaders?
    }

    var performRequestParameters: PerformRequestParameters?
    var customResponse: Any?
    func performRequest<T: Codable>(
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?
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
