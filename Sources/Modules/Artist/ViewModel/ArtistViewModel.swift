//
//  ArtistViewModel.swift
//  MementoFM
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol ArtistViewModelDelegate: class {
  func artistViewModel(_ viewModel: ArtistViewModel, didSelectTagWithName name: String)
  func artistViewModel(_ viewModel: ArtistViewModel, didSelectArtist artist: Artist)
}

protocol ArtistViewModelProtocol {
  var title: String { get }
  var sectionDataSources: [ArtistSectionDataSource] { get }
}

class ArtistViewModel: ArtistViewModelProtocol {
  typealias Dependencies = HasArtistService

  private let artist: Artist
  private let dependencies: Dependencies
  private let sectionViewModels: [ArtistSectionViewModel]

  weak var delegate: ArtistViewModelDelegate?

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

    topTagsSectionViewModel.delegate = self
    similarArtistsSectionViewModel.delegate = self

  }

  var title: String {
    return artist.name
  }
}

extension ArtistViewModel: ArtistTopTagsSectionViewModelDelegate {
  func artistTopTagsSectionViewModel(_ viewModel: ArtistTopTagsSectionViewModel, didSelectTagWithName name: String) {
    delegate?.artistViewModel(self, didSelectTagWithName: name)
  }
}

extension ArtistViewModel: ArtistSimilarArtistsSectionViewModelDelegate {
  func artistSimilarArtistSectionViewModel(_ viewModel: ArtistSimilarArtistsSectionViewModel,
                                           didSelectArtist artist: Artist) {
    delegate?.artistViewModel(self, didSelectArtist: artist)
  }
}
