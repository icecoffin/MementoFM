//
//  ArtistSimilarsSectionViewModelFactory.swift
//  MementoFM
//

import Foundation

protocol ArtistSimilarsSectionTabViewModelFactoryProtocol {
    func makeTabViewModels(for artist: Artist,
                           dependencies: ArtistSimilarsSectionViewModel.Dependencies,
                           delegate: SimilarsSectionTabViewModelDelegate) -> [ArtistSimilarsSectionViewModelProtocol]
}

final class ArtistSimilarsSectionTabViewModelFactory: ArtistSimilarsSectionTabViewModelFactoryProtocol {
    func makeTabViewModels(for artist: Artist,
                           dependencies: ArtistSimilarsSectionViewModel.Dependencies,
                           delegate: SimilarsSectionTabViewModelDelegate) -> [ArtistSimilarsSectionViewModelProtocol] {
        let localRequestStrategy = SimilarArtistsLocalRequestStrategy(dependencies: dependencies)
        let localTabViewModel = SimilarsSectionTabViewModel(artist: artist,
                                                            canSelectSimilarArtists: true,
                                                            requestStrategy: localRequestStrategy,
                                                            dependencies: dependencies)

        let remoteRequestStrategy = SimilarArtistsRemoteRequestStrategy(dependencies: dependencies)
        let lastFMTabViewModel = SimilarsSectionTabViewModel(artist: artist,
                                                             canSelectSimilarArtists: false,
                                                             requestStrategy: remoteRequestStrategy,
                                                             dependencies: dependencies)
        localTabViewModel.delegate = delegate
        return [localTabViewModel, lastFMTabViewModel]
    }
}
