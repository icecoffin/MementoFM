//
//  UICollectionView+Reusable.swift
//  MementoFM
//
//  Created by Dani on 04.07.2021.
//  Copyright © 2021 icecoffin. All rights reserved.
//

import UIKit

extension UICollectionView {
    public func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    public func register<T: UICollectionReusableView>(_: T.Type, forSupplementaryViewOfKind kind: String) {
        register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    public func dequeueReusableCell<T: UICollectionViewCell>(
        ofType: T.Type,
        withReuseIdentifier reuseIdentifier: String = T.reuseIdentifier,
        for indexPath: IndexPath
    ) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError("Couldn't dequeue \(T.self); is it registered in the collection view?")
        }
        return cell
    }

    public func dequeueReusableView<T: UICollectionReusableView>(
        ofType: T.Type,
        kind: String,
        reuseIdentifier: String = T.reuseIdentifier,
        for indexPath: IndexPath
    ) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind,
                                                          withReuseIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError("Couldn't dequeue \(T.self); is it registered in the collection view?")
        }
        return view
    }
}
