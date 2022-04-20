//
//  LastFMNetworkService.swift
//  MementoFM
//
//  Created by Daniel on 27/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import Combine

final class LastFMNetworkService: NetworkService {
    // MARK: - Private properties

    private let baseURL: URL
    private let queue = OperationQueue()

    // MARK: - Init

    init(baseURL: URL = NetworkConstants.LastFM.baseURL, maxConcurrentOperationCount: Int = 5) {
        self.baseURL = baseURL
        queue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }

    // MARK: - Public methods

    func performRequest<T: Codable>(method: HTTPMethod,
                                    parameters: Parameters?,
                                    encoding: ParameterEncoding,
                                    headers: HTTPHeaders?) -> Promise<T> {
        return Promise { seal in
            let operation = LastFMNetworkOperation<T>(url: baseURL,
                                                      parameters: parameters,
                                                      encoding: encoding,
                                                      headers: headers) { result in
                                                        switch result {
                                                        case .success(let response):
                                                            seal.fulfill(response)
                                                        case .failure(let error):
                                                            if !error.isCancelled {
                                                                seal.reject(error)
                                                            }
                                                        }
            }
            operation.onCancel = {
                seal.reject(PMKError.cancelled)
            }
            queue.addOperation(operation)
        }
    }

    func performRequest<T: Codable>(method: HTTPMethod,
                                    parameters: Parameters?,
                                    encoding: ParameterEncoding,
                                    headers: HTTPHeaders?) -> AnyPublisher<T, Error> {
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

    func cancelPendingRequests() {
        // TODO: PromiseKit: Pending Promise deallocated! This is usually a bug
        queue.cancelAllOperations()
    }
}
