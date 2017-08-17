//
//  UserService.swift
//  MementoFM
//
//  Created by Daniel on 30/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

class UserService {
  private let realmService: RealmService
  private let networkService: LastFMNetworkService

  init(realmService: RealmService, networkService: LastFMNetworkService) {
    self.realmService = realmService
    self.networkService = networkService
  }

  func getLibrary(for user: String, limit: Int = 200, progress: ((Progress) -> Void)?) -> Promise<[Artist]> {
    return Promise { fulfill, reject in
      let initialIndex = 1
      getLibraryPage(withIndex: initialIndex, for: user, limit: limit).then { [unowned self] page -> Void in
        if page.totalPages <= initialIndex {
          fulfill(page.artists)
          return
        }

        let totalProgress = Progress(totalUnitCount: Int64(page.totalPages - 1))
        let pagePromises = (initialIndex+1...page.totalPages).map { index in
          return self.getLibraryPage(withIndex: index, for: user, limit: limit).always {
            totalProgress.completedUnitCount += 1
            progress?(totalProgress)
          }
        }

        when(fulfilled: pagePromises).then { pages -> Void in
          let artists = ([page] + pages).flatMap { $0.artists }
          fulfill(artists)
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

  private func getLibraryPage(withIndex index: Int, for user: String, limit: Int) -> Promise<LibraryPage> {
    let parameters: [String: Any] = ["method": "library.getartists",
                                     "api_key": Keys.LastFM.apiKey,
                                     "user": user,
                                     "format": "json",
                                     "page": index,
                                     "limit": limit]
    return networkService.performRequest(parameters: parameters)
  }

  func getRecentTracks(for user: String, from: TimeInterval, limit: Int = 200, progress: ((Progress) -> Void)?) -> Promise<[Track]> {
    return Promise { fulfill, reject in
      let initialIndex = 1
      getRecentTracksPage(withIndex: initialIndex, for: user, from: from, limit: limit).then { [unowned self] response -> Void in
        let page = response.recentTracksPage
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

        when(fulfilled: pagePromises).then { pageResponses -> Void in
          let pages = pageResponses.map({ $0.recentTracksPage })
          let tracks = ([page] + pages).flatMap({ $0.tracks })
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

  private func getRecentTracksPage(withIndex index: Int, for user: String, from: TimeInterval, limit: Int) -> Promise<RecentTracksPageResponse> {
    let parameters: [String: Any] = ["method": "user.getrecenttracks",
                                     "api_key": Keys.LastFM.apiKey,
                                     "user": user,
                                     "from": from,
                                     "extended": 1,
                                     "format": "json",
                                     "page": index,
                                     "limit": limit]
    return networkService.performRequest(parameters: parameters)
  }

  func clearUserData() -> Promise<Void> {
    return realmService.write { realm in
      realm.delete(realm.objects(RealmArtist.self))
      realm.delete(realm.objects(RealmTag.self))
    }
  }
}
