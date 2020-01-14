//
//  LastFMNetworkOperation.swift
//  MementoFM
//
//  Created by Daniel on 21/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire
import Mapper

final class LastFMNetworkOperation<T: Mappable>: AsynchronousOperation {
    typealias CompletionHandler = (Result<T>) -> Void

    private let url: URLConvertible
    private let method: HTTPMethod
    private let parameters: Parameters?
    private let encoding: ParameterEncoding
    private let headers: HTTPHeaders?
    private let completionHandler: CompletionHandler

    weak var request: Request?
    var onCancel: (() -> Void)?

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

    override func main() {
        request = Alamofire.request(url, method: method, parameters: parameters,
                                    encoding: encoding, headers: headers).responseJSON { response in
                                        self.handleResponse(response)
        }
    }

    private func handleResponse(_ response: DataResponse<Any>) {
        let result = response.result
        switch result {
        case .success(let value):
            if let errorResponse = try? LastFMErrorResponse.from(value) {
                self.completionHandler(.failure(errorResponse.error))
            } else {
                do {
                    let object = try T.from(value)
                    self.completionHandler(.success(object))
                } catch {
                    self.completionHandler(.failure(error))
                }
            }
        case .failure(let error):
            self.completionHandler(.failure(error))
        }
        self.completeOperation()
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
