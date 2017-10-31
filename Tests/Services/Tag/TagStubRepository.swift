//
//  TagStubRepository.swift
//  MementoFM
//
//  Created by Daniel on 29/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class TagStubRepository: TagRepository {
  private let tagsPerArtist: Int
  private let shouldFailWithError: Bool

  init(tagsPerArtist: Int, shouldFailWithError: Bool) {
    self.tagsPerArtist = tagsPerArtist
    self.shouldFailWithError = shouldFailWithError
  }

  func getTopTags(for artist: String) -> Promise<TopTagsResponse> {
    if shouldFailWithError {
      return Promise(error: NSError(domain: "MementoFM", code: 1, userInfo: nil))
    } else {
      let tags = ModelFactory.generateTags(inAmount: tagsPerArtist, for: artist)
      let topTagsList = TopTagsList(tags: tags)
      let response = TopTagsResponse(topTagsList: topTagsList)
      return Promise(value: response)
    }
  }
}
