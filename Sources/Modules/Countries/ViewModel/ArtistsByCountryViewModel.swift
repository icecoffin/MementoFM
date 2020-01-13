//
//  ArtistsByCountryViewModel.swift
//  MementoFM
//
//  Created by Dani on 13.01.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

final class ArtistsByCountryViewModel: ArtistListViewModel {
  typealias Dependencies = HasArtistService

  // MARK: - Properties

  private let country: CountryType
  private let dependencies: Dependencies
  private let originalPredicate: NSPredicate

  private let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    return numberFormatter
  }()

  private lazy var artists: AnyPersistentMappedCollection<Artist> = {
    let playcountSort = NSSortDescriptor(key: "playcount", ascending: false)
    return self.dependencies.artistService.artists(filteredUsing: self.originalPredicate, sortedBy: [playcountSort])
  }()

  weak var delegate: ArtistListViewModelDelegate?

  var didStartLoading: (() -> Void)?
  var didFinishLoading: (() -> Void)?
  var didUpdateData: ((_ isEmpty: Bool) -> Void)?
  var didChangeStatus: ((String) -> Void)?
  var didReceiveError: ((Error) -> Void)?

  var itemCount: Int {
    return artists.count
  }

  var title: String {
    return country.displayName
  }

  // MARK: - Init

  init(country: CountryType, dependencies: Dependencies) {
    self.country = country
    self.dependencies = dependencies

    switch country {
    case .named(let name):
      self.originalPredicate = NSPredicate(format: "country == %@", name)
    case .unknown:
      self.originalPredicate = NSPredicate(format: "country == nil OR country == ''")
    }
  }

  // MARK: - Public methods

  func requestDataIfNeeded(currentTimestamp: TimeInterval, minTimeInterval: TimeInterval) { }

  func artistViewModel(at indexPath: IndexPath) -> LibraryArtistCellViewModel {
    let artist = artists[indexPath.row]
    let viewModel = LibraryArtistCellViewModel(artist: artist,
                                               index: indexPath.row + 1,
                                               numberFormatter: numberFormatter)
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
    self.didUpdateData?(artists.isEmpty)
  }
}
