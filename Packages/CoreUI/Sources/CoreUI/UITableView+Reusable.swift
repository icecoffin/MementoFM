//
//  UITableView+Reusable.swift
//  MementoFM
//
//  Created by Dani on 04.07.2021.
//  Copyright © 2021 icecoffin. All rights reserved.
//

import UIKit

extension UITableView {
    public func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    public func register<T: UITableViewHeaderFooterView>(_: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    public func dequeueReusableCell<T: UITableViewCell>(
        ofType: T.Type,
        withIdentifier identifier: String = T.reuseIdentifier
    ) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Couldn't dequeue \(T.self); is it registered in the table view?")
        }
        return cell
    }

    public func dequeueReusableCell<T: UITableViewCell>(
        ofType: T.Type,
        withIdentifier identifier: String = T.reuseIdentifier,
        for indexPath: IndexPath
    ) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Couldn't dequeue \(T.self); is it registered in the table view?")
        }
        return cell
    }

    public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(
        ofType: T.Type,
        withIdentifier identifier: String = T.reuseIdentifier
    ) -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T else {
            fatalError("Couldn't dequeue \(T.self); is it registered in the table view?")
        }

        return view
    }
}
