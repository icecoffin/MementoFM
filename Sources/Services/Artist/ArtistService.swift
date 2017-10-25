//
//  ArtistService.swift
//  MementoFM
//
//  Created by Daniel on 27/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift

fileprivate let numberOfTopTags = 5

struct TopTagsRequestProgress {
  let progress: Progress
  let artist: Artist
  let topTagsList: TopTagsList
}

class ArtistService {
  private let realmService: RealmService
  private let repository: ArtistRepository

  init(realmService: RealmService, repository: ArtistRepository) {
    self.realmService = realmService
    self.repository = repository
  }

  func getLibrary(for user: String, limit: Int = 200, progress: ((Progress) -> Void)?) -> Promise<[Artist]> {
    return Promise { fulfill, reject in
      let initialIndex = 1
      repository.getLibraryPage(withIndex: initialIndex, for: user, limit: limit).then { [unowned self] pageResponse -> Void in
        let page = pageResponse.libraryPage
        if page.totalPages <= initialIndex {
          fulfill(page.artists)
          return
        }

        let totalProgress = Progress(totalUnitCount: Int64(page.totalPages - 1))
        let pagePromises = (initialIndex+1...page.totalPages).map { index in
          return self.repository.getLibraryPage(withIndex: index, for: user, limit: limit).always {
            totalProgress.completedUnitCount += 1
            progress?(totalProgress)
          }
        }

        when(fulfilled: pagePromises).then { pageResponses -> Void in
          let pages = pageResponses.map({ $0.libraryPage })
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

  func saveArtists(_ artists: [Artist]) -> Promise<Void> {
    return realmService.save(artists)
  }

  func artistsNeedingTagsUpdate() -> [Artist] {
    let predicate = NSPredicate(format: "needsTagsUpdate == \(true)")
    return realmService.objects(Artist.self, filteredBy: predicate)
  }

  func getArtistsWithIntersectingTopTags(for artist: Artist) -> Promise<[Artist]> {
    return DispatchQueue.global().promise { () -> [Artist] in
      let topTagNames = artist.topTags.map({ $0.name })
      let predicate = NSPredicate(format: "ANY tags.name IN %@ AND name != %@", topTagNames, artist.name)
      return self.realmService.objects(Artist.self, filteredBy: predicate)
    }
  }

  func updateArtist(_ artist: Artist, with tags: [Tag]) -> Promise<Artist> {
    let updatedArtist = Artist(name: artist.name, playcount: artist.playcount, urlString: artist.urlString,
                               imageURLString: artist.imageURLString, needsTagsUpdate: false, tags: tags, topTags: artist.topTags)
    return self.realmService.save(updatedArtist).then {
      return updatedArtist
    }
  }

  func calculateTopTagsForAllArtists(ignoring ignoredTags: [IgnoredTag],
                                     numberOfTopTags: Int = numberOfTopTags) -> Promise<Void> {
    return DispatchQueue.global().promise { () -> [Artist] in
      let calculator = ArtistTopTagsCalculator(ignoredTags: ignoredTags, numberOfTopTags: numberOfTopTags)
      let artists = self.realmService.objects(Artist.self)
      return artists.map({ return calculator.calculateTopTags(for: $0) })
    }.then { artists in
      return self.realmService.save(artists)
    }
  }

  func calculateTopTags(for artist: Artist,
                        ignoring ignoredTags: [IgnoredTag],
                        numberOfTopTags: Int = numberOfTopTags) -> Promise<Void> {
    let calculator = ArtistTopTagsCalculator(ignoredTags: ignoredTags, numberOfTopTags: numberOfTopTags)
    let updatedArtist = calculator.calculateTopTags(for: artist)
    return realmService.save(updatedArtist)
  }

  func artists(filteredUsing predicate: NSPredicate? = nil,
               sortedBy sortDescriptors: [SortDescriptor]) -> RealmMappedCollection<RealmArtist, Artist> {
    return realmService.mappedCollection(filteredUsing: predicate, sortedBy: sortDescriptors)
  }

  func getSimilarArtists(for artist: Artist, limit: Int = 20) -> Promise<[Artist]> {
    return repository.getSimilarArtists(for: artist, limit: limit).then { response in
      let artistNames = response.similarArtistList.similarArtists.map({ $0.name })
      let predicate = NSPredicate(format: "name in %@", artistNames)
      let artists = self.realmService.objects(Artist.self, filteredBy: predicate)
      return Promise(value: artists)
    }
  }
}
