//
//  ArtistSimilarsSectionViewModel.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - ArtistSimilarsSectionViewModelProtocol

protocol ArtistSimilarsSectionViewModelProtocol: AnyObject {
    var didUpdateData: AnyPublisher<Void, Error> { get }

    var numberOfSimilarArtists: Int { get }
    var hasSimilarArtists: Bool { get }
    var canSelectSimilarArtists: Bool { get }

    var isLoading: Bool { get }

    var emptyDataSetText: String { get }
    func getSimilarArtists()
    func cellViewModel(at indexPath: IndexPath) -> SimilarArtistCellViewModelProtocol
    func selectArtist(at indexPath: IndexPath)
}

// MARK: - ArtistSimilarsSectionViewModelDelegate

protocol ArtistSimilarsSectionViewModelDelegate: AnyObject {
    func artistSimilarsSectionViewModel(_ viewModel: ArtistSimilarsSectionViewModel,
                                        didSelectArtist artist: Artist)
}

// MARK: - ArtistSimilarsSectionViewModel

final class ArtistSimilarsSectionViewModel: ArtistSimilarsSectionViewModelProtocol {
    typealias Dependencies = HasArtistService

    // MARK: - Private properties

    private var tabViewModels: [ArtistSimilarsSectionViewModelProtocol] = []
    private var didUpdateDataSubject = PassthroughSubject<Void, Error>()
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Public properties

    private(set) lazy var currentTabViewModel: ArtistSimilarsSectionViewModelProtocol = self.tabViewModels[0]

    var didUpdateData: AnyPublisher<Void, Error> {
        return didUpdateDataSubject.eraseToAnyPublisher()
    }

    weak var delegate: ArtistSimilarsSectionViewModelDelegate?

    var sectionHeaderText: String? {
        return "Similar artists from your library".unlocalized
    }

    var numberOfSimilarArtists: Int {
        return currentTabViewModel.numberOfSimilarArtists
    }

    var hasSimilarArtists: Bool {
        return currentTabViewModel.hasSimilarArtists
    }

    var canSelectSimilarArtists: Bool {
        return currentTabViewModel.canSelectSimilarArtists
    }

    var isLoading: Bool {
        return currentTabViewModel.isLoading
    }

    var emptyDataSetText: String {
        return currentTabViewModel.emptyDataSetText
    }

    // MARK: - Init

    init(artist: Artist,
         dependencies: Dependencies,
         tabViewModelFactory: ArtistSimilarsSectionTabViewModelFactoryProtocol = ArtistSimilarsSectionTabViewModelFactory()) {
        tabViewModels = tabViewModelFactory.makeTabViewModels(for: artist, dependencies: dependencies, delegate: self)
        setup()
    }

    // MARK: - Private properties

    private func setup() {
        for tabViewModel in tabViewModels {
            tabViewModel.didUpdateData.sink { [weak self, unowned tabViewModel] completion in
                if case .failure = completion, tabViewModel === self?.currentTabViewModel {
                    self?.didUpdateDataSubject.send(completion: completion)
                }
            } receiveValue: { [weak self, unowned tabViewModel] _ in
                if tabViewModel === self?.currentTabViewModel {
                    self?.didUpdateDataSubject.send()
                }
            }
            .store(in: &cancelBag)
        }
    }

    // MARK: - Public methods

    func getSimilarArtists() {
        currentTabViewModel.getSimilarArtists()
    }

    func cellViewModel(at indexPath: IndexPath) -> SimilarArtistCellViewModelProtocol {
        return currentTabViewModel.cellViewModel(at: indexPath)
    }

    func selectArtist(at indexPath: IndexPath) {
        currentTabViewModel.selectArtist(at: indexPath)
    }

    func selectTab(at index: Int) {
        currentTabViewModel = tabViewModels[index]
        didUpdateDataSubject.send()
        currentTabViewModel.getSimilarArtists()
    }
}

// MARK: - SimilarsSectionTabViewModelDelegate

extension ArtistSimilarsSectionViewModel: SimilarsSectionTabViewModelDelegate {
    func similarsSectionTabViewModel(_ viewModel: SimilarsSectionTabViewModel,
                                     didSelectArtist artist: Artist) {
        delegate?.artistSimilarsSectionViewModel(self, didSelectArtist: artist)
    }
}
