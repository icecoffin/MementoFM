//
//  ArtistSimilarArtistsSectionViewModel.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

class ArtistSimilarArtistsSectionViewModel: ArtistSectionViewModel {
  typealias Dependencies = HasRealmGateway

  private let artist: Artist
  private let dependencies: Dependencies

  private var cellViewModels: [SimilarArtistCellViewModel]
  private(set) var isLoading: Bool = true

  var onDidUpdateCellViewModels: (() -> Void)?

  required init(artist: Artist, dependencies: Dependencies) {
    self.artist = artist
    self.dependencies = dependencies
    self.cellViewModels = []
    calculateSimilarArtists()
  }

  var numberOfSimilarArtists: Int {
    return cellViewModels.count
  }

  var hasSimilarArtists: Bool {
    return !cellViewModels.isEmpty
  }

  var sectionHeaderText: String? {
    return "Similar artists".unlocalized
  }

  var emptyDataSetText: String {
    return "There are no similar artists.".unlocalized
  }

  func cellViewModel(at indexPath: IndexPath) -> SimilarArtistCellViewModel {
    return cellViewModels[indexPath.item]
  }

  private func calculateSimilarArtists() {
    dependencies.realmGateway.getArtistsWithIntersectingTopTags(for: artist).then { [weak self] artists -> Void in
      self?.createCellViewModels(from: artists)
    }.then(on: DispatchQueue.main) { [weak self] _ -> Void in
      self?.isLoading = false
      self?.onDidUpdateCellViewModels?()
    }.noError()
  }

  private func createCellViewModels(from artists: [Artist]) {
    cellViewModels = artists.map({ artist -> (Artist, [String]) in
      let commonTags = self.artist.intersectingTopTagNames(with: artist)
      return (artist, commonTags)
    }).filter({ (_, commonTags) in
      return commonTags.count >= 2
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
