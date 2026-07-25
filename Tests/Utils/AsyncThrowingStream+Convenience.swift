//
//  AsyncThrowingStream+Convenience.swift
//  MementoFM
//
//  Created by Dani on 25.07.26.
//

extension AsyncThrowingStream where Failure == Error {
    init(elements: [Element]) {
        self.init { continuation in
            elements.forEach { continuation.yield($0) }
            continuation.finish()
        }
    }

    init(error: Failure) {
        self.init { continuation in
            continuation.finish(throwing: error)
        }
    }

    func collect() async throws -> [Element] {
        var values: [Element] = []

        for try await value in self {
            values.append(value)
        }

        return values
    }
}
