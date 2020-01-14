//
//  Dispatcher.swift
//  MementoFM
//
//  Created by Dani on 30/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol Dispatcher {
    var queue: DispatchQueue { get }

    func dispatch(_ work: @escaping () -> Void)
    func dispatch<T>(_ work: @escaping () -> T) -> Guarantee<T>
    func dispatch<T>(_ work: @escaping () throws -> T) -> Promise<T>
}

final class AsyncDispatcher: Dispatcher {
    static let main = AsyncDispatcher(queue: .main)
    static let global = AsyncDispatcher(queue: .global())

    let queue: DispatchQueue

    init(queue: DispatchQueue) {
        self.queue = queue
    }

    func dispatch(_ work: @escaping () -> Void) {
        queue.async(execute: work)
    }

    func dispatch<T>(_ work: @escaping () -> T) -> Guarantee<T> {
        return queue.async(.promise, execute: work)
    }

    func dispatch<T>(_ work: @escaping () throws -> T) -> Promise<T> {
        return queue.async(.promise, execute: work)
    }
}
