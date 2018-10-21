//
//  ArtistsByTagViewModel.swift
//  MementoFM
//
//  Created by Daniel on 19/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

class ArtistsByTagViewModel: ArtistListViewModel {
  typealias Dependencies = HasArtistService

  private let tagName: String
  private let dependencies: Dependencies
  private let originalPredicate: NSPredicate

  weak var delegate: ArtistListViewModelDelegate?

  var onDidStartLoading: (() -> Void)?
  var onDidFinishLoading: (() -> Void)?
  var onDidUpdateData: ((_ isEmpty: Bool) -> Void)?
  var onDidChangeStatus: ((String) -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  private lazy var artists: RealmMappedCollection<Artist> = {
    let playcountSort = SortDescriptor(keyPath: "playcount", ascending: false)
    return self.dependencies.artistService.artists(filteredUsing: self.originalPredicate, sortedBy: [playcountSort])
  }()

  init(tagName: String, dependencies: Dependencies) {
    self.tagName = tagName
    self.dependencies = dependencies
    self.originalPredicate = NSPredicate(format: "ANY topTags.name == %@", tagName)
  }

  var itemCount: Int {
    return artists.count
  }

  var title: String {
    return tagName
  }

  func requestDataIfNeeded() { }

  func artistViewModel(at indexPath: IndexPath) -> LibraryArtistCellViewModel {
    let artist = artists[indexPath.row]
    let viewModel = LibraryArtistCellViewModel(artist: artist)
    return viewModel
  }

  func selectArtist(at indexPath: IndexPath) {
    let artist = artists[indexPath.row]
    self.delegate?.artistListViewModel(self, didSelectArtist: artist)
  }

  func performSearch(withText text: String) {
    let filterPredicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
    let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [originalPredicate, filterPredicate])
    artists.predicate = compoundPredicate
    self.onDidUpdateData?(artists.isEmpty)
  }
}
