//
//  ArtistViewModel.swift
//  MementoFM
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class ArtistViewModel {
  typealias Dependencies = HasRealmGateway

  private let artist: Artist
  private let dependencies: Dependencies
  private let sectionViewModels: [ArtistSectionViewModel]

  let sectionDataSources: [ArtistSectionDataSource]

  init(artist: Artist, dependencies: Dependencies) {
    self.artist = artist
    self.dependencies = dependencies

    let infoSectionViewModel = ArtistInfoSectionViewModel(artist: artist)
    let topTagsSectionViewModel = ArtistTopTagsSectionViewModel(artist: artist)
    let similarArtistsSectionViewModel = ArtistSimilarArtistsSectionViewModel(artist: artist, dependencies: dependencies)
    sectionViewModels = [infoSectionViewModel, topTagsSectionViewModel, similarArtistsSectionViewModel]

    let infoSectionDataSource = ArtistInfoSectionDataSource(viewModel: infoSectionViewModel)
    let topTagsSectionDataSource = ArtistTopTagsSectionDataSource(viewModel: topTagsSectionViewModel)
    let similarArtistsSectionDataSource = ArtistSimilarArtistsSectionDataSource(viewModel: similarArtistsSectionViewModel)
    sectionDataSources = [infoSectionDataSource, topTagsSectionDataSource, similarArtistsSectionDataSource]
  }

  var title: String {
    return artist.name
  }
}
