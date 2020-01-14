//
//  TestDispatcher.swift
//  MementoFM
//
//  Created by Dani on 30/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit
@testable import MementoFM

final class TestDispatcher: Dispatcher {
    let queue: DispatchQueue = .main

    func dispatch(_ work: @escaping () -> Void) {
        work()
    }

    func dispatch<T>(_ work: @escaping () -> T) -> Guarantee<T> {
        let result = work()
        return Guarantee { resolver in
            resolver(result)
        }
    }

    func dispatch<T>(_ work: @escaping () throws -> T) -> Promise<T> {
        return Promise { seal in
            do {
                let result = try work()
                seal.fulfill(result)
            } catch {
                seal.reject(error)
            }
        }
    }
}
