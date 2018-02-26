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

struct TopTagsRequestProgress {
  let progress: Progress
  let artist: Artist
  let topTagsList: TopTagsList
}

protocol ArtistServiceProtocol: class {
  func getLibrary(for user: String, limit: Int, progress: ((Progress) -> Void)?) -> Promise<[Artist]>
  func saveArtists(_ artists: [Artist]) -> Promise<Void>
  func artistsNeedingTagsUpdate() -> [Artist]
  func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist]
  func updateArtist(_ artist: Artist, with tags: [Tag]) -> Promise<Artist>
  func calculateTopTagsForAllArtists(using calculator: ArtistTopTagsCalculating) -> Promise<Void>
  func calculateTopTags(for artist: Artist, using calculator: ArtistTopTagsCalculating) -> Promise<Void>
  func artists(filteredUsing predicate: NSPredicate?,
               sortedBy sortDescriptors: [SortDescriptor]) -> RealmMappedCollection<Artist>
  func getSimilarArtists(for artist: Artist, limit: Int) -> Promise<[Artist]>
}

extension ArtistServiceProtocol {
  func getLibrary(for user: String, progress: ((Progress) -> Void)?) -> Promise<[Artist]> {
    return getLibrary(for: user, limit: 200, progress: progress)
  }

  func getLibrary(for user: String) -> Promise<[Artist]> {
    return getLibrary(for: user, limit: 200, progress: nil)
  }

  func artists(sortedBy sortDescriptors: [SortDescriptor]) -> RealmMappedCollection<Artist> {
    return artists(filteredUsing: nil, sortedBy: sortDescriptors)
  }

  func getSimilarArtists(for artist: Artist) -> Promise<[Artist]> {
    return getSimilarArtists(for: artist, limit: 20)
  }
}

class ArtistService: ArtistServiceProtocol {
  private let realmService: RealmService
  private let repository: ArtistRepository

  init(realmService: RealmService, repository: ArtistRepository) {
    self.realmService = realmService
    self.repository = repository
  }

  func getLibrary(for user: String, limit: Int, progress: ((Progress) -> Void)?) -> Promise<[Artist]> {
    return Promise { seal in
      let initialIndex = 1
      repository.getLibraryPage(withIndex: initialIndex, for: user, limit: limit).done { pageResponse in
        let page = pageResponse.libraryPage
        if page.totalPages <= initialIndex {
          seal.fulfill(page.artists)
          return
        }

        let totalProgress = Progress(totalUnitCount: Int64(page.totalPages - 1))
        let pagePromises = (initialIndex+1...page.totalPages).map { index in
          return self.repository.getLibraryPage(withIndex: index, for: user, limit: limit).ensure {
            totalProgress.completedUnitCount += 1
            progress?(totalProgress)
          }
        }

        when(fulfilled: pagePromises).done { pageResponses in
          let pages = pageResponses.map({ $0.libraryPage })
          let artists = ([page] + pages).flatMap { $0.artists }
          seal.fulfill(artists)
        }.catch { error in
          if !error.isCancelled {
            seal.reject(error)
          }
        }
      }.catch { error in
        if !error.isCancelled {
          seal.reject(error)
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

  func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist] {
    let topTagNames = artist.topTags.map({ $0.name })
    let predicate = NSPredicate(format: "ANY topTags.name IN %@ AND name != %@", topTagNames, artist.name)
    return self.realmService.objects(Artist.self, filteredBy: predicate)
  }

  func updateArtist(_ artist: Artist, with tags: [Tag]) -> Promise<Artist> {
    let updatedArtist = artist.updatingTags(to: tags, needsTagsUpdate: false)
    return self.realmService.save(updatedArtist).then { _ -> Promise<Artist> in
      return .value(updatedArtist)
    }
  }

  func calculateTopTagsForAllArtists(using calculator: ArtistTopTagsCalculating) -> Promise<Void> {
    return DispatchQueue.global().async(.promise) { () -> [Artist] in
      let artists = self.realmService.objects(Artist.self)
      return artists.map({ return calculator.calculateTopTags(for: $0) })
    }.then { artists in
      return self.realmService.save(artists)
    }
  }

  func calculateTopTags(for artist: Artist, using calculator: ArtistTopTagsCalculating) -> Promise<Void> {
    let updatedArtist = calculator.calculateTopTags(for: artist)
    return realmService.save(updatedArtist)
  }

  func artists(filteredUsing predicate: NSPredicate? = nil,
               sortedBy sortDescriptors: [SortDescriptor]) -> RealmMappedCollection<Artist> {
    return realmService.mappedCollection(filteredUsing: predicate, sortedBy: sortDescriptors)
  }

  func getSimilarArtists(for artist: Artist, limit: Int) -> Promise<[Artist]> {
    return repository.getSimilarArtists(for: artist, limit: limit).then { response -> Promise<[Artist]> in
      let artistNames = response.similarArtistList.similarArtists.map({ $0.name })
      let predicate = NSPredicate(format: "name in %@", artistNames)
      let artists = self.realmService.objects(Artist.self, filteredBy: predicate)
      return .value(artists)
    }
  }
}
