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
  var didUpdateData: (() -> Void)? { get set }
  var didReceiveError: ((Error) -> Void)? { get set }

  var title: String { get }
  var sectionDataSources: [ArtistSectionDataSource] { get }
}

final class ArtistViewModel: ArtistViewModelProtocol {
  typealias Dependencies = HasArtistService

  private let artist: Artist
  private let dependencies: Dependencies

  weak var delegate: ArtistViewModelDelegate?

  var didUpdateData: (() -> Void)?
  var didReceiveError: ((Error) -> Void)?

  let sectionDataSources: [ArtistSectionDataSource]

  var title: String {
    return artist.name
  }

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

    similarsSectionDataSource.didUpdateData = { [unowned self] in
      self.didUpdateData?()
    }
    similarsSectionDataSource.didReceiveError = { [unowned self] error in
      self.didReceiveError?(error)
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
