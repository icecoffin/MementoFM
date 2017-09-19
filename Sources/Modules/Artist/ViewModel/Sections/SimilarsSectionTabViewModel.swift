//
//  SimilarsSectionTabViewModel.swift
//  MementoFM
//
//  Created by Daniel on 19/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol SimilarsSectionTabViewModelDelegate: class {
  func similarsSectionTabViewModel(_ viewModel: SimilarsSectionTabViewModel,
                                   didSelectArtist artist: Artist)
}

class SimilarsSectionTabViewModel: ArtistSimilarsSectionViewModelProtocol {
  typealias Dependencies = HasArtistService

  private let artist: Artist
  private let requestStrategy: SimilarArtistsRequestStrategy
  private let dependencies: Dependencies

  private var cellViewModels: [SimilarArtistCellViewModel] = []
  private(set) var isLoading: Bool = false

  var onDidUpdateCellViewModels: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  weak var delegate: SimilarsSectionTabViewModelDelegate?

  var numberOfSimilarArtists: Int {
    return cellViewModels.count
  }

  var hasSimilarArtists: Bool {
    return !cellViewModels.isEmpty
  }

  var emptyDataSetText: String {
    return "There are no similar artists.".unlocalized
  }

  init(artist: Artist, requestStrategy: SimilarArtistsRequestStrategy, dependencies: Dependencies) {
    self.artist = artist
    self.requestStrategy = requestStrategy
    self.dependencies = dependencies
    self.cellViewModels = []
  }

  func cellViewModel(at indexPath: IndexPath) -> SimilarArtistCellViewModelProtocol {
    return cellViewModels[indexPath.item]
  }

  func selectArtist(at indexPath: IndexPath) {
    let cellViewModel = cellViewModels[indexPath.row]
    delegate?.similarsSectionTabViewModel(self, didSelectArtist: cellViewModel.artist)
  }

  func getSimilarArtists() {
    if !isLoading, cellViewModels.isEmpty {
      calculateSimilarArtists()
    } else {
      onDidUpdateCellViewModels?()
    }
  }

  private func calculateSimilarArtists() {
    isLoading = true
    requestStrategy.getSimilarArtists(for: artist).then { [weak self] artists -> Void in
      self?.createCellViewModels(from: artists)
      }.then(on: DispatchQueue.main) { _ -> Void in
        self.isLoading = false
        self.onDidUpdateCellViewModels?()
      }.catch { error in
        self.isLoading = false
        self.onDidReceiveError?(error)
    }
  }

  private func createCellViewModels(from artists: [Artist]) {
    cellViewModels = artists.map({ artist -> (Artist, [String]) in
      let commonTags = self.artist.intersectingTopTagNames(with: artist)
      return (artist, commonTags)
    }).filter({ (_, commonTags) in
      return commonTags.count >= requestStrategy.minNumberOfIntersectingTags
    }).sorted(by: { (first: (artist: Artist, commonTags: [String]), second: (artist: Artist, commonTags: [String])) in
      let commonTagsCount1 = first.commonTags.count
      let commonTagsCount2 = second.commonTags.count
      if commonTagsCount1 == commonTagsCount2 {
        return first.artist.playcount > second.artist.playcount
      }
      return commonTagsCount1 > commonTagsCount2
    }).map({ (artist, commonTags) in SimilarArtistCellViewModel(artist: artist, commonTags: commonTags) })
  }
}
