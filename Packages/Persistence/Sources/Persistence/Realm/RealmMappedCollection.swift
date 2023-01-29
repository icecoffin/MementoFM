//
//  RealmMappedCollection.swift
//  MementoFM
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift
import TransientModels

public final class RealmMappedCollection<Element: TransientEntity>: PersistentMappedCollection {
    public typealias Transform = (Element.PersistentType) -> Element

    // MARK: - Private properties

    private let realm: Realm
    lazy private var results: Results<Object> = {
        return self.fetchResults()
    }()

    // MARK: - Public properties

    public var count: Int {
        return results.count
    }

    public var isEmpty: Bool {
        return results.isEmpty
    }

    public var sortDescriptors: [NSSortDescriptor] {
        didSet {
            refetchResults()
        }
    }

    public var predicate: NSPredicate? {
        didSet {
            refetchResults()
        }
    }

    // MARK: - Init

    public init(realm: Realm, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]) {
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

    public subscript(index: Int) -> Element.PersistentType.TransientType {
        guard let item = results[index] as? Element.PersistentType else {
            fatalError("The provided Element.PersistentType is not a Realm Object subclass")
        }

        return item.toTransient()
    }
}

extension RealmSwift.SortDescriptor {
    init?(nsSortDescriptor: NSSortDescriptor) {
        guard let key = nsSortDescriptor.key else { return nil }

        self = RealmSwift.SortDescriptor(keyPath: key, ascending: nsSortDescriptor.ascending)
    }
}
