//
//  TagService.swift
//  MementoFM
//
//  Created by Daniel on 10/08/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

class TagService {
  private let realmService: RealmService
  private let networkService: LastFMNetworkService

  init(realmService: RealmService, networkService: LastFMNetworkService) {
    self.realmService = realmService
    self.networkService = networkService
  }

  func getTopTags(for artists: [Artist], progress: @escaping ((TopTagsRequestProgress) -> Void)) -> Promise<Void> {
    return Promise { fulfill, reject in
      let totalProgress = Progress(totalUnitCount: Int64(artists.count))

      let promises = artists.map { artist in
        return getTopTags(for: artist.name).then { topTagsResponse -> Void in
          totalProgress.completedUnitCount += 1
          let topTagsList = topTagsResponse.topTagsList
          progress(TopTagsRequestProgress(progress: totalProgress, artist: artist, topTagsList: topTagsList))
        }.catch { error in
          if !error.isCancelledError {
            reject(error)
          }
        }
      }

      when(fulfilled: promises).then { _ in
        fulfill(())
      }.catch { error in
        if !error.isCancelledError {
          reject(error)
        }
      }
    }
  }

  private func getTopTags(for artist: String) -> Promise<TopTagsResponse> {
    let parameters: [String: Any] = ["method": "artist.gettoptags",
                                     "api_key": Keys.LastFM.apiKey,
                                     "artist": artist,
                                     "format": "json"]

    return networkService.performRequest(parameters: parameters)
  }

  func getAllTopTags() -> Promise<[Tag]> {
    return DispatchQueue.global().promise { () -> [Tag] in
      let artists = self.realmService.objects(Artist.self)
      return artists.flatMap { return $0.topTags }
    }
  }
}
