//
//  Coordinator.swift
//  MementoFM
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var didFinish: (() -> Void)? { get set }

    func start()
    func addChildCoordinator(_ coordinator: Coordinator)
    func removeChildCoordinator(_ coordinator: Coordinator)
    func startChildren()
    func removeAllChildren()
}

extension Coordinator {
    public func addChildCoordinator(_ coordinator: Coordinator) {
        coordinator.didFinish = { [unowned self, unowned coordinator] in
            self.removeChildCoordinator(coordinator)
        }
        childCoordinators.append(coordinator)
    }

    public func removeChildCoordinator(_ coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(where: {$0 === coordinator}) {
            childCoordinators.remove(at: index)
        }
    }

    public func startChildren() {
        childCoordinators.forEach { $0.start() }
    }

    public func removeAllChildren() {
        childCoordinators.removeAll()
    }
}
