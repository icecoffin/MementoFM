//
//  Coordinator.swift
//  MementoFM
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var didFinish: (() -> Void)? { get set }

    func start()
    func addChildCoordinator(_ coordinator: Coordinator)
    func removeChildCoordinator(_ coordinator: Coordinator)
    func startChildren()
    func removeAllChildren()
}

extension Coordinator {
    func addChildCoordinator(_ coordinator: Coordinator) {
        coordinator.didFinish = { [unowned self, unowned coordinator] in
            self.removeChildCoordinator(coordinator)
        }
        childCoordinators.append(coordinator)
    }

    func removeChildCoordinator(_ coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(where: {$0 === coordinator}) {
            childCoordinators.remove(at: index)
        }
    }

    func startChildren() {
        childCoordinators.forEach { $0.start() }
    }

    func removeAllChildren() {
        childCoordinators.removeAll()
    }
}
