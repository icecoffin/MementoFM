//
//  StubArtistEmptyRepository.swift
//  MementoFM
//
//  Created by Daniel on 05/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit
import Combine

class StubArtistEmptyRepository: ArtistRepository {
    func getLibraryPage(withIndex index: Int, for user: String, limit: Int) -> Promise<LibraryPageResponse> {
        fatalError()
    }

    func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<SimilarArtistListResponse, Error> {
        fatalError()
    }
}
