//
//  ArtistSimilarsSectionViewModelFactory.swift
//  MementoFM
//

import Foundation

// MARK: - ArtistSimilarsSectionTabViewModelFactoryProtocol

// swiftlint:disable:next type_name
protocol ArtistSimilarsSectionTabViewModelFactoryProtocol {
    @MainActor
    func makeTabViewModels(
        for artist: Artist,
        dependencies: ArtistSimilarsSectionViewModel.Dependencies,
        delegate: SimilarsSectionTabViewModelDelegate
    ) -> [ArtistSimilarsSectionViewModelProtocol]
}

// MARK: - ArtistSimilarsSectionTabViewModelFactory

final class ArtistSimilarsSectionTabViewModelFactory: ArtistSimilarsSectionTabViewModelFactoryProtocol {
    @MainActor
    func makeTabViewModels(
        for artist: Artist,
        dependencies: ArtistSimilarsSectionViewModel.Dependencies,
        delegate: SimilarsSectionTabViewModelDelegate
    ) -> [ArtistSimilarsSectionViewModelProtocol] {
        let localRequestStrategy = SimilarArtistsLocalRequestStrategy(dependencies: dependencies)
        let localTabViewModel = SimilarsSectionTabViewModel(
            artist: artist,
            canSelectSimilarArtists: true,
            requestStrategy: localRequestStrategy
        )

        let remoteRequestStrategy = SimilarArtistsRemoteRequestStrategy(dependencies: dependencies)
        let lastFMTabViewModel = SimilarsSectionTabViewModel(
            artist: artist,
            canSelectSimilarArtists: false,
            requestStrategy: remoteRequestStrategy
        )
        localTabViewModel.delegate = delegate
        return [localTabViewModel, lastFMTabViewModel]
    }
}
