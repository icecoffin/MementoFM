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
  private let shouldFailWithError: Bool
  private let tagProvider: ((String) -> [Tag])

  init(shouldFailWithError: Bool, tagProvider: @escaping ((String) -> [Tag])) {
    self.shouldFailWithError = shouldFailWithError
    self.tagProvider = tagProvider
  }

  func getTopTags(for artist: String) -> Promise<TopTagsResponse> {
    if shouldFailWithError {
      return Promise(error: NSError(domain: "MementoFM", code: 1, userInfo: nil))
    } else {
      let tags = tagProvider(artist)
      let topTagsList = TopTagsList(tags: tags)
      let response = TopTagsResponse(topTagsList: topTagsList)
      return Promise(value: response)
    }
  }
}
