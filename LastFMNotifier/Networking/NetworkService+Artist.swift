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

protocol ArtistNetworkService {
  func getTopTags(for artists: [Artist], progress: @escaping ((Artist, TopTagsList) -> Void)) -> Promise<Void>
}

extension NetworkService: ArtistNetworkService {
  func getTopTags(for artists: [Artist], progress: @escaping ((Artist, TopTagsList) -> Void)) -> Promise<Void> {
    return Promise { fulfill, reject in
      let promises = artists.map { artist in
        return getTopTags(for: artist.name).then { topTagsList in
          progress(artist, topTagsList)
        }
      }

      when(fulfilled: promises.makeIterator(), concurrently: 1).then { _ in
        fulfill()
      }.catch { error in
        reject(error)
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
          reject(error)
        }
      }
      queue.addOperation(operation)
    }
  }
}
