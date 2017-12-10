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
  var onDidUpdateData: (() -> Void)? { get set }
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
  private(set) lazy var currentTabViewModel: ArtistSimilarsSectionViewModelProtocol = self.tabViewModels[0]

  var onDidUpdateData: (() -> Void)?
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

  init(artist: Artist,
       tabViewModelFactory: ArtistSimilarsSectionTabViewModelFactoryProtocol = ArtistSimilarsSectionTabViewModelFactory(),
       dependencies: Dependencies) {
    tabViewModels = tabViewModelFactory.makeTabViewModels(for: artist, dependencies: dependencies, delegate: self)
    setup()
  }

  private func setup() {
    for tabViewModel in tabViewModels {
      tabViewModel.onDidUpdateData = { [weak self, unowned tabViewModel] in
        guard let `self` = self else {
          return
        }

        if tabViewModel === self.currentTabViewModel {
          self.onDidUpdateData?()
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
    onDidUpdateData?()
    currentTabViewModel.getSimilarArtists()
  }
}

extension ArtistSimilarsSectionViewModel: SimilarsSectionTabViewModelDelegate {
  func similarsSectionTabViewModel(_ viewModel: SimilarsSectionTabViewModel,
                                   didSelectArtist artist: Artist) {
    delegate?.artistSimilarsSectionViewModel(self, didSelectArtist: artist)
  }
}
