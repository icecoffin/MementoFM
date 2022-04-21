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
    var didUpdateData: AnyPublisher<Void, Error> { get }

    var title: String { get }
    var sectionDataSources: [ArtistSectionDataSource] { get }
}

// MARK: - ArtistViewModel

final class ArtistViewModel: ArtistViewModelProtocol {
    typealias Dependencies = HasArtistService

    // MARK: - Private properties

    private let artist: Artist
    private let dependencies: Dependencies

    private var didUpdateDataSubject = PassthroughSubject<Void, Error>()
    private var cancelBag = Set<AnyCancellable>()

    weak var delegate: ArtistViewModelDelegate?

    // MARK: - Public properties

    var didUpdateData: AnyPublisher<Void, Error> {
        return didUpdateDataSubject.eraseToAnyPublisher()
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

        similarsSectionDataSource.didUpdateData
            .sink { [weak self] completion in
                self?.didUpdateDataSubject.send(completion: completion)
            } receiveValue: { [weak self] in
                self?.didUpdateDataSubject.send()
            }
            .store(in: &cancelBag)
    }
}

// MARK: - ArtistTopTagsSectionViewModelDelegate

extension ArtistViewModel: ArtistTopTagsSectionViewModelDelegate {
    func artistTopTagsSectionViewModel(_ viewModel: ArtistTopTagsSectionViewModel,
                                       didSelectTagWithName name: String) {
        delegate?.artistViewModel(self, didSelectTagWithName: name)
    }
}

// MARK: - ArtistSimilarsSectionViewModelDelegate

extension ArtistViewModel: ArtistSimilarsSectionViewModelDelegate {
    func artistSimilarsSectionViewModel(_ viewModel: ArtistSimilarsSectionViewModel,
                                        didSelectArtist artist: Artist) {
        delegate?.artistViewModel(self, didSelectArtist: artist)
    }
}
