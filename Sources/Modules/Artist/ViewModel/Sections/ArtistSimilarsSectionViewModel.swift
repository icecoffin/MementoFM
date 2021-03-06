//
//  ArtistSimilarsSectionViewModel.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

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

protocol ArtistSimilarsSectionViewModelDelegate: AnyObject {
    func artistSimilarsSectionViewModel(_ viewModel: ArtistSimilarsSectionViewModel,
                                        didSelectArtist artist: Artist)
}

final class ArtistSimilarsSectionViewModel: ArtistSimilarsSectionViewModelProtocol {
    typealias Dependencies = HasArtistService

    private var tabViewModels: [ArtistSimilarsSectionViewModelProtocol] = []
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

    init(artist: Artist,
         tabViewModelFactory: ArtistSimilarsSectionTabViewModelFactoryProtocol = ArtistSimilarsSectionTabViewModelFactory(),
         dependencies: Dependencies) {
        tabViewModels = tabViewModelFactory.makeTabViewModels(for: artist, dependencies: dependencies, delegate: self)
        setup()
    }

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

extension ArtistSimilarsSectionViewModel: SimilarsSectionTabViewModelDelegate {
    func similarsSectionTabViewModel(_ viewModel: SimilarsSectionTabViewModel,
                                     didSelectArtist artist: Artist) {
        delegate?.artistSimilarsSectionViewModel(self, didSelectArtist: artist)
    }
}
