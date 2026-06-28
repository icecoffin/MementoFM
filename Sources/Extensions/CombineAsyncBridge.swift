//
//  CombineAsyncBridge.swift
//  MementoFM
//
//  Created by Dani on 28.06.26.
//

import Combine

extension Future where Failure == Error {
    convenience init(
        _ operation: @escaping () async throws -> Output
    ) {
        self.init { promise in
            Task {
                do {
                    let value = try await operation()
                    promise(.success(value))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
