//
//  ArtistService.swift
//  MementoFM
//
//  Created by Daniel on 27/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

fileprivate let numberOfTopTags = 5

struct TopTagsRequestProgress {
  let progress: Progress
  let artist: Artist
  let topTagsList: TopTagsList
}

class ArtistService {
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
        fulfill()
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

  func saveArtists(_ artists: [Artist]) -> Promise<Void> {
    return realmService.save(artists)
  }

  func artistsNeedingTagsUpdate() -> [Artist] {
    let predicate = NSPredicate(format: "needsTagsUpdate == \(true)")
    return realmService.objects(Artist.self, filteredBy: predicate)
  }

  func getArtistsWithIntersectingTopTags(for artist: Artist) -> Promise<[Artist]> {
    return dispatch_promise(DispatchQueue.global()) { () -> [Artist] in
      let topTagNames = artist.topTags.map({ $0.name })
      let predicate = NSPredicate(format: "ANY tags.name IN %@ AND name != %@", topTagNames, artist.name)
      return self.realmService.objects(Artist.self, filteredBy: predicate)
    }
  }

  func updateArtist(_ artist: Artist, with tags: [Tag]) -> Promise<Void> {
    let updatedArtist = Artist(name: artist.name, playcount: artist.playcount, urlString: artist.urlString,
                               imageURLString: artist.imageURLString, needsTagsUpdate: false, tags: tags, topTags: artist.topTags)
    return self.realmService.save(updatedArtist)
  }

  func calculateTopTagsForAllArtists(ignoring ignoredTags: [IgnoredTag],
                                     numberOfTopTags: Int = numberOfTopTags) -> Promise<Void> {
    return dispatch_promise(DispatchQueue.global()) { _ -> [Artist] in
      let calculator = ArtistTopTagsCalculator(ignoredTags: ignoredTags, numberOfTopTags: numberOfTopTags)
      let artists = self.realmService.objects(Artist.self)
      return artists.map({ return calculator.calculateTopTags(for: $0) })
    }.then { artists in
      return self.realmService.save(artists)
    }
  }
}
