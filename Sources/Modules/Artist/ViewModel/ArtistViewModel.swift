//
//  ArtistViewModel.swift
//  MementoFM
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - ArtistViewModelDelegate

protocol ArtistViewModelDelegate: AnyObject {
    func artistViewModel(_ viewModel: ArtistViewModel, didSelectTagWithName name: String)
    func artistViewModel(_ viewModel: ArtistViewModel, didSelectArtist artist: Artist)
}

// MARK: - ArtistViewModelProtocol

protocol ArtistViewModelProtocol: AnyObject {
    var didUpdate: AnyPublisher<Result<Void, Error>, Never> { get }

    var title: String { get }
    var sectionDataSources: [ArtistSectionDataSource] { get }
}

// MARK: - ArtistViewModel

final class ArtistViewModel: ArtistViewModelProtocol {
    typealias Dependencies = HasArtistService

    // MARK: - Private properties

    private let artist: Artist
    private let dependencies: Dependencies

    private var didUpdateSubject = PassthroughSubject<Result<Void, Error>, Never>()
    private var cancelBag = Set<AnyCancellable>()

    weak var delegate: ArtistViewModelDelegate?

    // MARK: - Public properties

    var didUpdate: AnyPublisher<Result<Void, Error>, Never> {
        return didUpdateSubject.eraseToAnyPublisher()
    }

    let sectionDataSources: [ArtistSectionDataSource]

    var title: String {
        return artist.name
    }

    // MARK: - Init

    init(artist: Artist, dependencies: Dependencies) {
        self.artist = artist
        self.dependencies = dependencies

        let topTagsSectionViewModel = ArtistTopTagsSectionViewModel(artist: artist)
        let similarsSectionViewModel = ArtistSimilarsSectionViewModel(artist: artist, dependencies: dependencies)

        let topTagsSectionDataSource = ArtistTopTagsSectionDataSource(viewModel: topTagsSectionViewModel)
        let similarsSectionDataSource = ArtistSimilarsSectionDataSource(viewModel: similarsSectionViewModel)
        sectionDataSources = [topTagsSectionDataSource, similarsSectionDataSource]

        topTagsSectionViewModel.delegate = self
        similarsSectionViewModel.delegate = self

        similarsSectionDataSource.didUpdate
            .sink(receiveValue: { [weak self] result in
                self?.didUpdateSubject.send(result)
            })
            .store(in: &cancelBag)
    }
}

// MARK: - ArtistTopTagsSectionViewModelDelegate

extension ArtistViewModel: ArtistTopTagsSectionViewModelDelegate {
    func artistTopTagsSectionViewModel(
        _ viewModel: ArtistTopTagsSectionViewModel,
        didSelectTagWithName name: String
    ) {
        delegate?.artistViewModel(self, didSelectTagWithName: name)
    }
}

// MARK: - ArtistSimilarsSectionViewModelDelegate

extension ArtistViewModel: ArtistSimilarsSectionViewModelDelegate {
    func artistSimilarsSectionViewModel(
        _ viewModel: ArtistSimilarsSectionViewModel,
        didSelectArtist artist: Artist
    ) {
        delegate?.artistViewModel(self, didSelectArtist: artist)
    }
}
