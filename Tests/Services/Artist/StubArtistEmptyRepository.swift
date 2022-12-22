//
//  StubArtistEmptyRepository.swift
//  MementoFM
//
//  Created by Daniel on 05/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine
import TransientModels

final class StubArtistEmptyRepository: ArtistRepository {
    func getLibraryPage(withIndex index: Int, for user: String, limit: Int) -> AnyPublisher<LibraryPageResponse, Error> {
        fatalError()
    }

    func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<SimilarArtistListResponse, Error> {
        fatalError()
    }
}
