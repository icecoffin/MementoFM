//
//  ArtistListViewModel.swift
//  MementoFM
//
//  Created by Daniel on 19/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - ArtistListViewModelDelegate

protocol ArtistListViewModelDelegate: AnyObject {
    func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist)
}

// MARK: - ArtistListViewModel

protocol ArtistListViewModel: AnyObject {
    var delegate: ArtistListViewModelDelegate? { get set }

    var isLoading: AnyPublisher<Bool, Never> { get }
    var didUpdate: AnyPublisher<Result<Bool, Error>, Never> { get }
    var status: AnyPublisher<String, Never> { get }

    var itemCount: Int { get }
    var title: String { get }
    var searchBarPlaceholder: String { get }

    func requestDataIfNeeded(currentTimestamp: TimeInterval, minTimeInterval: TimeInterval)
    func artistViewModel(at indexPath: IndexPath) -> LibraryArtistCellViewModel
    func selectArtist(at indexPath: IndexPath)
    func performSearch(withText text: String)
}

extension ArtistListViewModel {
    func requestDataIfNeeded() {
        requestDataIfNeeded(currentTimestamp: Date().timeIntervalSince1970, minTimeInterval: 30)
    }

    var searchBarPlaceholder: String {
        return "Search".unlocalized
    }
}
