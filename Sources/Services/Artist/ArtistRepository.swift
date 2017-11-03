//
//  ArtistRepository.swift
//  MementoFM
//

import Foundation
import PromiseKit

protocol ArtistRepository: class {
  func getLibraryPage(withIndex index: Int, for user: String, limit: Int) -> Promise<LibraryPageResponse>
  func getSimilarArtists(for artist: Artist, limit: Int) -> Promise<SimilarArtistListResponse>
}

class ArtistNetworkRepository: ArtistRepository {
  private let networkService: LastFMNetworkService

  init(networkService: LastFMNetworkService) {
    self.networkService = networkService
  }

  func getLibraryPage(withIndex index: Int, for user: String, limit: Int) -> Promise<LibraryPageResponse> {
    let parameters: [String: Any] = ["method": "library.getartists",
                                     "api_key": Keys.LastFM.apiKey,
                                     "user": user,
                                     "format": "json",
                                     "page": index,
                                     "limit": limit]

    return networkService.performRequest(parameters: parameters)
  }

  func getSimilarArtists(for artist: Artist, limit: Int) -> Promise<SimilarArtistListResponse> {
    let parameters: [String: Any] = ["method": "artist.getsimilar",
                                     "api_key": Keys.LastFM.apiKey,
                                     "artist": artist.name,
                                     "format": "json",
                                     "limit": limit]

    return networkService.performRequest(parameters: parameters)
  }
}