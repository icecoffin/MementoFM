//
//  NetworkService+User.swift
//  MementoFM
//
//  Created by Daniel on 06/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

protocol UserNetworkService {
  func getRecentTracks(for user: String, from: TimeInterval, limit: Int, progress: ((Progress) -> Void)?) -> Promise<[Track]>
}

extension UserNetworkService {
  func getRecentTracks(for user: String, from: TimeInterval, limit: Int = 200, progress: ((Progress) -> Void)?) -> Promise<[Track]> {
    return getRecentTracks(for: user, from: from, limit: limit, progress: progress)
  }
}

extension NetworkService: UserNetworkService {
  func getRecentTracks(for user: String, from: TimeInterval, limit: Int, progress: ((Progress) -> Void)?) -> Promise<[Track]> {
    return Promise { fulfill, reject in
      let initialIndex = 1
      getRecentTracksPage(withIndex: initialIndex, for: user, from: from, limit: limit).then { [unowned self] page -> Void in

        if page.totalPages <= initialIndex {
          fulfill(page.tracks)
          return
        }

        let totalProgress = Progress(totalUnitCount: Int64(page.totalPages - 1))
        let pagePromises = (initialIndex+1...page.totalPages).map { index in
          return self.getRecentTracksPage(withIndex: index, for: user, from: from, limit: limit).always {
            totalProgress.completedUnitCount += 1
            progress?(totalProgress)
          }
        }

        when(fulfilled: pagePromises).then { pages -> Void in
          let tracks = ([page] + pages).flatMap { $0.tracks }
          fulfill(tracks)
          }.catch { error in
            if !error.isCancelledError {
              reject(error)
            }
          }
        }.catch { error in
          if !error.isCancelledError {
            reject(error)
          }
      }
    }
  }

  private func getRecentTracksPage(withIndex index: Int, for user: String, from: TimeInterval, limit: Int) -> Promise<RecentTracksPage> {
    let parameters: [String: Any] = ["method": "user.getrecenttracks",
                                     "api_key": Keys.LastFM.apiKey,
                                     "user": user,
                                     "from": from,
                                     "extended": 1,
                                     "format": "json",
                                     "page": index,
                                     "limit": limit]

    return Promise { fulfill, reject in
      let operation = LastFMNetworkOperation<RecentTracksPageResponse>(url: baseURL, parameters: parameters) { result in
        switch result {
        case .success(let pageResponse):
          fulfill(pageResponse.recentTracksPage)
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
