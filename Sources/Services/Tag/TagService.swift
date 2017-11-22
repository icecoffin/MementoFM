//
//  TagService.swift
//  MementoFM
//
//  Created by Daniel on 10/08/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol TagServiceProtocol: class {
  func getTopTags(for artists: [Artist], progress: ((TopTagsRequestProgress) -> Void)?) -> Promise<Void>
  func getAllTopTags() -> [Tag]
}

extension TagServiceProtocol {
  func getTopTags(for artists: [Artist]) -> Promise<Void> {
    return getTopTags(for: artists, progress: nil)
  }
}

class TagService: TagServiceProtocol {
  private let realmService: RealmService
  private let repository: TagRepository

  init(realmService: RealmService, repository: TagRepository) {
    self.realmService = realmService
    self.repository = repository
  }

  func getTopTags(for artists: [Artist], progress: ((TopTagsRequestProgress) -> Void)?) -> Promise<Void> {
    return Promise { fulfill, reject in
      let totalProgress = Progress(totalUnitCount: Int64(artists.count))

      let promises = artists.map { artist in
        return repository.getTopTags(for: artist.name).then { topTagsResponse -> Void in
          totalProgress.completedUnitCount += 1
          let topTagsList = topTagsResponse.topTagsList
          progress?(TopTagsRequestProgress(progress: totalProgress, artist: artist, topTagsList: topTagsList))
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

  func getAllTopTags() -> [Tag] {
    let artists = self.realmService.objects(Artist.self)
    return artists.flatMap { return $0.topTags }
  }
}
