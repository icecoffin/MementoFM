//
//  LastFMNetworkOperation.swift
//  MementoFM
//
//  Created by Daniel on 21/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire

final class LastFMNetworkOperation<T: Codable>: AsynchronousOperation {
    typealias CompletionHandler = (Result<T, Error>) -> Void

    // MARK: - Private properties

    private let url: URLConvertible
    private let method: HTTPMethod
    private let parameters: Parameters?
    private let encoding: ParameterEncoding
    private let headers: HTTPHeaders?
    private let completionHandler: CompletionHandler

    // MARK: - Public properties

    weak var request: Request?
    var onCancel: (() -> Void)?

    // MARK: - Init

    init(url: URLConvertible,
         method: HTTPMethod = .get,
         parameters: Parameters? = nil,
         encoding: ParameterEncoding = URLEncoding.default,
         headers: HTTPHeaders? = nil,
         completionHandler: @escaping CompletionHandler) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.encoding = encoding
        self.headers = headers
        self.completionHandler = completionHandler

        super.init()
    }

    // MARK: - Private methods

    private func handleResponse(_ response: DataResponse<Data, AFError>) {
        let jsonDecoder = JSONDecoder()
        let result = response.result
        switch result {
        case .success(let value):
            if let errorResponse = try? jsonDecoder.decode(LastFMError.self, from: value) {
                self.completionHandler(.failure(errorResponse.error))
            } else {
                do {
                    let object = try jsonDecoder.decode(T.self, from: value)
                    self.completionHandler(.success(object))
                } catch {
                    log.debug(error)
                    self.completionHandler(.failure(error))
                }
            }
        case .failure(let error):
            self.completionHandler(.failure(error))
        }
        self.completeOperation()
    }

    // MARK: - Overrides

    override func main() {
        request = AF
            .request(url,
                     method: method,
                     parameters: parameters,
                     encoding: encoding,
                     headers: headers)
            .responseData { response in
                self.handleResponse(response)
            }
    }

    override func cancel() {
        super.cancel()

        onCancel?()
        request?.cancel()

        if isExecuting {
            completeOperation()
        }
    }
}
