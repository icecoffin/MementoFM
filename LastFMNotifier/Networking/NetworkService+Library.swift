//
//  NetworkService+Library.swift
//  LastFMNotifier
//
//  Created by Daniel on 06/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

protocol LibraryNetworkService {
  func getLibrary(for user: String, limit: Int, progress: ((Progress) -> Void)?) -> Promise<[Artist]>
}

extension LibraryNetworkService {
  func getLibrary(for user: String, limit: Int = 200, progress: ((Progress) -> Void)?) -> Promise<[Artist]> {
    return getLibrary(for: user, limit: limit, progress: progress)
  }
}

extension NetworkService: LibraryNetworkService {
  func getLibrary(for user: String, limit: Int, progress: ((Progress) -> Void)?) -> Promise<[Artist]> {
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
            reject(error)
          }
        }.catch { error in
          reject(error)
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

    return Promise { fulfill, reject in
      let operation = NetworkOperation(url: baseURL, parameters: parameters) { response in
        switch response.result {
        case .success(let value):
          do {
            let pageResponse = try LibraryPageResponse.from(value)
            fulfill(pageResponse.libraryPage)
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
