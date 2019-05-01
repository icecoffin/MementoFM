//
//  SimilarArtistsRequestStrategy.swift
//  MementoFM
//
//  Created by Daniel on 16/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol SimilarArtistsRequestStrategy {
  typealias Dependencies = HasArtistService

  var minNumberOfIntersectingTags: Int { get }

  func getSimilarArtists(for artist: Artist) -> Promise<[Artist]>
}

final class SimilarArtistsLocalRequestStrategy: SimilarArtistsRequestStrategy {
  private let dependencies: Dependencies

  var minNumberOfIntersectingTags: Int {
    return 2
  }

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  func getSimilarArtists(for artist: Artist) -> Promise<[Artist]> {
    let similarArtists = dependencies.artistService.artistsWithIntersectingTopTags(for: artist)
    return .value(similarArtists)
  }
}

final class SimilarArtistsRemoteRequestStrategy: SimilarArtistsRequestStrategy {
  private let dependencies: Dependencies

  var minNumberOfIntersectingTags: Int {
    return 0
  }

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  func getSimilarArtists(for artist: Artist) -> Promise<[Artist]> {
    return dependencies.artistService.getSimilarArtists(for: artist)
  }
}
