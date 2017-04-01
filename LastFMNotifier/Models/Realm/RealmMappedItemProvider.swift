//
//  RealmMappedCollectionReuseStrategy.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

enum RealmMappedCollectionReuseStrategy {
  case cache, recreate
}

class RealmMappedItemProviderFactory {
  func provider<Element>(for strategy: RealmMappedCollectionReuseStrategy, using transformedItemProvider: @escaping ((Int) -> Element)) -> AnyRealmMappedItemProvider<Element> {
    switch strategy {
    case .cache:
      return AnyRealmMappedItemProvider(RealmMappedItemCachingProvider(transformedItemProvider: transformedItemProvider))
    case .recreate:
      return AnyRealmMappedItemProvider(RealmMappedItemRecreatingProvider(transformedItemProvider: transformedItemProvider))
    }
  }
}

protocol RealmMappedItemProvider {
  associatedtype Element

  var transformedItemProvider: ((Int) -> Element) { get }

  subscript(index: Int) -> Element { get }
  func handleUpdate(insertions: [Int], deletions: [Int], modifications: [Int])
  func clear()
}

private class _AnyRealmMappedItemProviderBase<Element>: RealmMappedItemProvider {
  var transformedItemProvider: ((Int) -> Element) {
    fatalError("Must override")
  }

  subscript(index: Int) -> Element {
    fatalError("Must override")
  }

  func handleUpdate(insertions: [Int], deletions: [Int], modifications: [Int]) {
    fatalError("Must override")
  }

  func clear() {
    fatalError("Must override")
  }
}

private class _AnyRealmMappedItemProviderBox<Concrete: RealmMappedItemProvider>: _AnyRealmMappedItemProviderBase<Concrete.Element> {
  var concrete: Concrete

  init(_ concrete: Concrete) {
    self.concrete = concrete
  }

  override var transformedItemProvider: ((Int) -> Concrete.Element) {
    return concrete.transformedItemProvider
  }

  override subscript(index: Int) -> Concrete.Element {
    return concrete[index]
  }

  override func handleUpdate(insertions: [Int], deletions: [Int], modifications: [Int]) {
    concrete.handleUpdate(insertions: insertions, deletions: deletions, modifications: modifications)
  }

  override func clear() {
    concrete.clear()
  }
}

class AnyRealmMappedItemProvider<Element>: RealmMappedItemProvider {
  private let box: _AnyRealmMappedItemProviderBase<Element>

  init<Concrete: RealmMappedItemProvider>(_ concrete: Concrete) where Concrete.Element == Element {
    box = _AnyRealmMappedItemProviderBox(concrete)
  }

  var transformedItemProvider: ((Int) -> Element) {
    return box.transformedItemProvider
  }

  subscript(index: Int) -> Element {
    return box[index]
  }

  func handleUpdate(insertions: [Int], deletions: [Int], modifications: [Int]) {
    box.handleUpdate(insertions: insertions, deletions: deletions, modifications: modifications)
  }

  func clear() {
    box.clear()
  }
}

class RealmMappedItemCachingProvider<Element>: RealmMappedItemProvider {
  var transformedItemProvider: ((Int) -> Element)

  init(transformedItemProvider: @escaping ((Int) -> Element)) {
    self.transformedItemProvider = transformedItemProvider
  }

  func handleUpdate(insertions: [Int], deletions: [Int], modifications: [Int]) {

  }

  subscript(index: Int) -> Element {
    return transformedItemProvider(index)
  }

  func clear() {

  }
}

class RealmMappedItemRecreatingProvider<Element>: RealmMappedItemProvider {
  private var transformedCache: [Int: Element] = [:]
  var transformedItemProvider: ((Int) -> Element)

  init(transformedItemProvider: @escaping ((Int) -> Element)) {
    self.transformedItemProvider = transformedItemProvider
  }

  func handleUpdate(insertions: [Int], deletions: [Int], modifications: [Int]) {

  }

  private func handle(deletions: [Int]) {
    for index in deletions.reversed() where index < transformedCache.count {
      transformedCache.removeValue(forKey: index)
    }
  }

  private func handle(insertions: [Int]) {
    insertions.reversed().forEach { index in
      transformedCache[index] = transformedItemProvider(index)
    }
  }

  private func handle(modifications: [Int]) {
    let count = transformedCache.count
    modifications.forEach { index in
      if index < count {
        transformedCache[index] = transformedItemProvider(index)
      }
    }
  }

  subscript(index: Int) -> Element {
    if let transformedValue = transformedCache[index] {
      return transformedValue
    }

    let transformedValue = transformedItemProvider(index)
    transformedCache[index] = transformedValue
    return transformedValue
  }

  func clear() {
    transformedCache.removeAll()
  }
}
