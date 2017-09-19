//
//  ArtistSimilarsSectionViewModel.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol ArtistSimilarsSectionViewModelProtocol: class {
  var onDidUpdateCellViewModels: (() -> Void)? { get set }
  var onDidReceiveError: ((Error) -> Void)? { get set }

  var numberOfSimilarArtists: Int { get }
  var hasSimilarArtists: Bool { get }

  var isLoading: Bool { get }

  var emptyDataSetText: String { get }
  func getSimilarArtists()
  func cellViewModel(at indexPath: IndexPath) -> SimilarArtistCellViewModelProtocol
  func selectArtist(at indexPath: IndexPath)
}

protocol ArtistSimilarsSectionViewModelDelegate: class {
  func artistSimilarsSectionViewModel(_ viewModel: ArtistSimilarsSectionViewModel,
                                      didSelectArtist artist: Artist)
}

class ArtistSimilarsSectionViewModel: ArtistSimilarsSectionViewModelProtocol {
  typealias Dependencies = HasArtistService

  private var tabViewModels: [ArtistSimilarsSectionViewModelProtocol] = []
  private(set) var currentTabViewModel: ArtistSimilarsSectionViewModelProtocol

  var onDidUpdateCellViewModels: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

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

  var isLoading: Bool {
    return currentTabViewModel.isLoading
  }

  var emptyDataSetText: String {
    return currentTabViewModel.emptyDataSetText
  }

  init(artist: Artist, dependencies: Dependencies) {
    let localRequestStrategy = SimilarArtistsLocalRequestStrategy(dependencies: dependencies)
    let localTabViewModel = SimilarsSectionTabViewModel(artist: artist,
                                                        requestStrategy: localRequestStrategy,
                                                        dependencies: dependencies)

    let remoteRequestStrategy = SimilarArtistsRemoteRequestStrategy(dependencies: dependencies)
    let lastFMTabViewModel = SimilarsSectionTabViewModel(artist: artist,
                                                         requestStrategy: remoteRequestStrategy,
                                                         dependencies: dependencies)
    currentTabViewModel = localTabViewModel

    tabViewModels = [localTabViewModel, lastFMTabViewModel]
    localTabViewModel.delegate = self
    setup()
  }

  private func setup() {
    for tabViewModel in tabViewModels {
      tabViewModel.onDidUpdateCellViewModels = { [weak self, unowned tabViewModel] in
        guard let `self` = self else {
          return
        }

        if tabViewModel === self.currentTabViewModel {
          self.onDidUpdateCellViewModels?()
        }
      }

      tabViewModel.onDidReceiveError = { [weak self, unowned tabViewModel] error in
        guard let `self` = self else {
          return
        }

        if tabViewModel === self.currentTabViewModel {
          self.onDidReceiveError?(error)
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
    onDidUpdateCellViewModels?()
    currentTabViewModel.getSimilarArtists()
  }
}

extension ArtistSimilarsSectionViewModel: SimilarsSectionTabViewModelDelegate {
  func similarsSectionTabViewModel(_ viewModel: SimilarsSectionTabViewModel,
                                   didSelectArtist artist: Artist) {
    delegate?.artistSimilarsSectionViewModel(self, didSelectArtist: artist)
  }
}
