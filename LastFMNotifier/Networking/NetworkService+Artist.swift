//
//  NetworkService+Artist.swift
//  LastFMNotifier
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

struct TopTagsRequestProgress {
  let progress: Progress
  let artist: Artist
  let topTagsList: TopTagsList
}

protocol ArtistNetworkService {
  func getTopTags(for artists: [Artist], progress: @escaping ((TopTagsRequestProgress) -> Void)) -> Promise<Void>
}

extension NetworkService: ArtistNetworkService {
  func getTopTags(for artists: [Artist], progress: @escaping ((TopTagsRequestProgress) -> Void)) -> Promise<Void> {
    return Promise { fulfill, reject in
      let totalProgress = Progress(totalUnitCount: Int64(artists.count))

      let promises = artists.map { artist in
        return getTopTags(for: artist.name).then { topTagsList -> Promise<Void> in
          totalProgress.completedUnitCount += 1
          progress(TopTagsRequestProgress(progress: totalProgress, artist: artist, topTagsList: topTagsList))
          return .void
        }.catch { error in
          if !error.isCancelledError {
            reject(error)
          }
        }
      }

      when(fulfilled: promises).then { _ in
        fulfill()
      }.catch { error in
        if !error.isCancelledError {
          reject(error)
        }
      }
    }
  }

  func getTopTags(for artist: String) -> Promise<TopTagsList> {
    let parameters: [String: Any] = ["method": "artist.gettoptags",
                                     "api_key": Keys.LastFM.apiKey,
                                     "artist": artist,
                                     "format": "json"]

    return Promise { fulfill, reject in
      let operation = NetworkOperation(url: baseURL, parameters: parameters) { response in
        switch response.result {
        case .success(let value):
          do {
            let topTagsResponse = try TopTagsResponse.from(value)
            fulfill(topTagsResponse.topTagsList)
          } catch {
            reject(error)
          }
        case .failure(let error):
          if !error.isCancelledError {
            reject(error)
          }
        }
      }
      operation.onCancel = {
        reject(NSError.cancelledError())
      }
      queue.addOperation(operation)
    }
  }
}
