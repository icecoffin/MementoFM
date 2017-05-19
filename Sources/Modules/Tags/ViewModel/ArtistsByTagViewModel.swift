//
//  ArtistsByTagViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 19/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

class ArtistsByTagViewModel: LibraryViewModelProtocol {
  typealias Dependencies = HasRealmGateway

  private let tagName: String
  private let dependencies: Dependencies
  private let originalPredicate: NSPredicate

  weak var delegate: LibraryViewModelDelegate?

  var onDidStartLoading: (() -> Void)?
  var onDidFinishLoading: (() -> Void)?
  var onDidUpdateData: ((_ isEmpty: Bool) -> Void)?
  var onDidChangeStatus: ((String) -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  fileprivate lazy var cellViewModels: RealmMappedCollection<RealmArtist, LibraryArtistCellViewModel> = {
    return self.createCellViewModels()
  }()

  init(tagName: String, dependencies: Dependencies) {
    self.tagName = tagName
    self.dependencies = dependencies
    self.originalPredicate = NSPredicate(format: "ANY topTags.name == %@", tagName)
  }

  private func createCellViewModels() -> RealmMappedCollection<RealmArtist, LibraryArtistCellViewModel> {
    let playcountSort = SortDescriptor(keyPath: "playcount", ascending: false)
    return RealmMappedCollection(realm: dependencies.realmGateway.mainQueueRealm,
                                 predicate: originalPredicate,
                                 sortDescriptors: [playcountSort],
                                 transform: { [unowned self] artist -> LibraryArtistCellViewModel in
                                  let viewModel = LibraryArtistCellViewModel(artist: artist.toTransient())
                                  viewModel.onSelection = { artist in
                                    self.delegate?.libraryViewModel(self, didSelectArtist: artist)
                                  }
                                  return viewModel
    })
  }

  var itemCount: Int {
    return cellViewModels.count
  }

  func requestDataIfNeeded(currentTimestamp: TimeInterval) { }

  func artistViewModel(at indexPath: IndexPath) -> LibraryArtistCellViewModel {
    return cellViewModels[indexPath.row]
  }

  func selectArtist(at indexPath: IndexPath) {
    let viewModel = cellViewModels[indexPath.row]
    viewModel.handleSelection()
  }

  func performSearch(withText text: String) {
    let filterPredicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
    let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [originalPredicate, filterPredicate])
    cellViewModels.predicate = compoundPredicate
    self.onDidUpdateData?(cellViewModels.isEmpty)
  }
}
