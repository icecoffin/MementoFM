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

    func cancelPendingRequests() {
        // TODO: PromiseKit: Pending Promise deallocated! This is usually a bug
        queue.cancelAllOperations()
    }
}
