//
//  ArtistSimilarsSectionViewModel.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: - ArtistSimilarsSectionViewModelProtocol

protocol ArtistSimilarsSectionViewModelProtocol: AnyObject {
    var didUpdateData: (() -> Void)? { get set }
    var didReceiveError: ((Error) -> Void)? { get set }

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

    // MARK: - Public properties

    private(set) lazy var currentTabViewModel: ArtistSimilarsSectionViewModelProtocol = self.tabViewModels[0]

    var didUpdateData: (() -> Void)?
    var didReceiveError: ((Error) -> Void)?

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
            tabViewModel.didUpdateData = { [weak self, unowned tabViewModel] in
                guard let self = self else {
                    return
                }

                if tabViewModel === self.currentTabViewModel {
                    self.didUpdateData?()
                }
            }

            tabViewModel.didReceiveError = { [weak self, unowned tabViewModel] error in
                guard let self = self else {
                    return
                }

                if tabViewModel === self.currentTabViewModel {
                    self.didReceiveError?(error)
                }
            }
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
        didUpdateData?()
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
