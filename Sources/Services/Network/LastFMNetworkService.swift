//
//  LastFMNetworkService.swift
//  MementoFM
//
//  Created by Daniel on 27/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire
import Combine

final class LastFMNetworkService: NetworkService {
    // MARK: - Private properties

    private let baseURL: URL

    // MARK: - Init

    init(baseURL: URL = NetworkConstants.LastFM.baseURL) {
        self.baseURL = baseURL
    }

    // MARK: - Public methods

    func performRequest<T: Codable>(
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?
    ) -> AnyPublisher<T, Error> {
        let publisher = AF
            .request(baseURL, method: method, parameters: parameters, headers: headers)
            .publishData()
            .value()
            .tryMap { value -> T in
                let jsonDecoder = JSONDecoder()
                if let errorResponse = try? jsonDecoder.decode(LastFMError.self, from: value) {
                    log.debug(errorResponse.error)
                    throw errorResponse.error
                } else {
                    do {
                        let object = try jsonDecoder.decode(T.self, from: value)
                        return object
                    } catch {
                        log.debug(error)
                        throw error
                    }
                }
            }
        return publisher
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
