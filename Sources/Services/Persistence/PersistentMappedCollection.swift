//
//  PersistentMappedCollection.swift
//  MementoFM
//
//  Created by Dani on 27/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation

protocol PersistentMappedCollection {
    associatedtype Element: TransientEntity

    var count: Int { get }
    var isEmpty: Bool { get }
    var sortDescriptors: [NSSortDescriptor] { get set }
    var predicate: NSPredicate? { get set }

    subscript(index: Int) -> Element.PersistentType.TransientType { get }
}

private class _AnyPersistentMappedCollectionBase<Element: TransientEntity>: PersistentMappedCollection {
    var count: Int {
        fatalError("Must override")
    }

    var isEmpty: Bool {
        fatalError("Must override")
    }

    var sortDescriptors: [NSSortDescriptor] {
        get { fatalError("Must override") }
        // swiftlint:disable:next unused_setter_value
        set { fatalError("Must override") }
    }

    var predicate: NSPredicate? {
        get { fatalError("Must override") }
        // swiftlint:disable:next unused_setter_value
        set { fatalError("Must override") }
    }

    subscript(index: Int) -> Element.PersistentType.TransientType {
        fatalError("Must override")
    }

    init() {
        guard type(of: self) != _AnyPersistentMappedCollectionBase.self else {
            fatalError("Cannot initialise, must subclass")
        }
    }
}

// swiftlint:disable:next line_length
private final class _AnyPersistentMappedCollectionBox<ConcreteCollection: PersistentMappedCollection>: _AnyPersistentMappedCollectionBase<ConcreteCollection.Element> {
    var concrete: ConcreteCollection

    override var count: Int {
        return concrete.count
    }

    override var isEmpty: Bool {
        return concrete.isEmpty
    }

    override var sortDescriptors: [NSSortDescriptor] {
        get { return concrete.sortDescriptors }
        set { concrete.sortDescriptors = newValue }
    }

    override var predicate: NSPredicate? {
        get { return concrete.predicate }
        set { concrete.predicate = newValue }
    }

    init(_ concrete: ConcreteCollection) {
        self.concrete = concrete
    }

    override subscript(index: Int) -> Element.PersistentType.TransientType {
        return concrete[index]
    }
}

final class AnyPersistentMappedCollection<Element: TransientEntity>: PersistentMappedCollection {
    private let box: _AnyPersistentMappedCollectionBase<Element>

    var count: Int {
        return box.count
    }

    var isEmpty: Bool {
        return box.isEmpty
    }

    var sortDescriptors: [NSSortDescriptor] {
        get { return box.sortDescriptors }
        set { box.sortDescriptors = newValue }
    }

    var predicate: NSPredicate? {
        get { return box.predicate }
        set { box.predicate = newValue }
    }

    init<Concrete: PersistentMappedCollection>(_ concrete: Concrete) where Concrete.Element == Element {
        box = _AnyPersistentMappedCollectionBox(concrete)
    }

    subscript(index: Int) -> Element.PersistentType.TransientType {
        return box[index]
    }
}
