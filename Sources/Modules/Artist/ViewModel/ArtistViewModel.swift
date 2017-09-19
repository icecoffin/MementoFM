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

protocol ArtistViewModelProtocol: class {
  var onDidUpdateData: (() -> Void)? { get set }
  var onDidReceiveError: ((Error) -> Void)? { get set }

  var title: String { get }
  var sectionDataSources: [ArtistSectionDataSource] { get }
}

class ArtistViewModel: ArtistViewModelProtocol {
  typealias Dependencies = HasArtistService

  private let artist: Artist
  private let dependencies: Dependencies

  weak var delegate: ArtistViewModelDelegate?

  var onDidUpdateData: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  let sectionDataSources: [ArtistSectionDataSource]

  var title: String {
    return artist.name
  }

  init(artist: Artist, dependencies: Dependencies) {
    self.artist = artist
    self.dependencies = dependencies

    let infoSectionViewModel = ArtistInfoSectionViewModel(artist: artist)
    let topTagsSectionViewModel = ArtistTopTagsSectionViewModel(artist: artist)
    let similarsSectionViewModel = ArtistSimilarsSectionViewModel(artist: artist, dependencies: dependencies)

    let infoSectionDataSource = ArtistInfoSectionDataSource(viewModel: infoSectionViewModel)
    let topTagsSectionDataSource = ArtistTopTagsSectionDataSource(viewModel: topTagsSectionViewModel)
    let similarsSectionDataSource = ArtistSimilarsSectionDataSource(viewModel: similarsSectionViewModel)
    sectionDataSources = [infoSectionDataSource, topTagsSectionDataSource, similarsSectionDataSource]

    topTagsSectionViewModel.delegate = self
    similarsSectionViewModel.delegate = self

    similarsSectionDataSource.onDidUpdateData = { [unowned self] in
      self.onDidUpdateData?()
    }
    similarsSectionDataSource.onDidReceiveError = { [unowned self] error in
      self.onDidReceiveError?(error)
    }
  }
}

extension ArtistViewModel: ArtistTopTagsSectionViewModelDelegate {
  func artistTopTagsSectionViewModel(_ viewModel: ArtistTopTagsSectionViewModel, didSelectTagWithName name: String) {
    delegate?.artistViewModel(self, didSelectTagWithName: name)
  }
}

extension ArtistViewModel: ArtistSimilarsSectionViewModelDelegate {
  func artistSimilarsSectionViewModel(_ viewModel: ArtistSimilarsSectionViewModel,
                                      didSelectArtist artist: Artist) {
    delegate?.artistViewModel(self, didSelectArtist: artist)
  }
}
