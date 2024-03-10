//
//  RealmMappedCollection.swift
//  MementoFM
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmMappedCollection<Element: TransientEntity>: PersistentMappedCollection {
    typealias Transform = (Element.PersistentType) -> Element

    // MARK: - Private properties

    private let realm: Realm
    lazy private var results: Results<Object> = {
        return self.fetchResults()
    }()

    // MARK: - Public properties

    var count: Int {
        return results.count
    }

    var isEmpty: Bool {
        return results.isEmpty
    }

    var sortDescriptors: [NSSortDescriptor] {
        didSet {
            refetchResults()
        }
    }

    var predicate: NSPredicate? {
        didSet {
            refetchResults()
        }
    }

    // MARK: - Init

    init(realm: Realm, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]) {
        self.realm = realm
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
    }

    // MARK: - Private methods

    private func fetchResults() -> Results<Object> {
        guard let type = Element.PersistentType.self as? Object.Type else {
            fatalError("The provided Element.PersistentType is not a Realm Object subclass")
        }

        let realmSortDescriptors = sortDescriptors.compactMap { SortDescriptor(nsSortDescriptor: $0) }
        let results = realm.objects(type).sorted(by: realmSortDescriptors)
        if let predicate = predicate {
            return results.filter(predicate)
        }

        return results
    }

    private func refetchResults() {
        results = fetchResults()
    }

    // MARK: - Subscript

    subscript(index: Int) -> Element {
        guard let item = results[index] as? Element.PersistentType else {
            fatalError("The provided Element.PersistentType is not a Realm Object subclass")
        }

        guard let transient = item.toTransient() as? Element else {
            fatalError("Can't convert item of type \(Element.PersistentType.self) to \(Element.self)")
        }

        return transient
    }
}

extension RealmSwift.SortDescriptor {
    init?(nsSortDescriptor: NSSortDescriptor) {
        guard let key = nsSortDescriptor.key else { return nil }

        self = RealmSwift.SortDescriptor(keyPath: key, ascending: nsSortDescriptor.ascending)
    }
}
