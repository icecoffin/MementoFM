//
//  ArtistsByCountryViewModel.swift
//  MementoFM
//
//  Created by Dani on 13.01.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import Foundation
import Combine
import TransientModels
import PersistenceInterface

final class ArtistsByCountryViewModel: ArtistListViewModel {
    typealias Dependencies = HasArtistService

    // MARK: - Private properties

    private let country: CountryType
    private let dependencies: Dependencies
    private let originalPredicate: NSPredicate

    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let didUpdateSubject = PassthroughSubject<Result<Bool, Error>, Never>()
    private let statusSubject = PassthroughSubject<String, Never>()

    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()

    private lazy var artists: AnyPersistentMappedCollection<Artist> = {
        let playcountSort = NSSortDescriptor(key: "playcount", ascending: false)
        return self.dependencies.artistService.artists(filteredUsing: self.originalPredicate, sortedBy: [playcountSort])
    }()

    // MARK: - Public properties

    weak var delegate: ArtistListViewModelDelegate?

    var isLoading: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }

    var didUpdate: AnyPublisher<Result<Bool, Error>, Never> {
        return didUpdateSubject.eraseToAnyPublisher()
    }

    var status: AnyPublisher<String, Never> {
        return statusSubject.eraseToAnyPublisher()
    }

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
        self.didUpdateSubject.send(.success(artists.isEmpty))
    }
}
