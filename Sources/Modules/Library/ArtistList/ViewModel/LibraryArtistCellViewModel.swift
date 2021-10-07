//
//  LibraryArtistCellViewModel.swift
//  MementoFM
//
//  Created by Daniel on 20/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

final class LibraryArtistCellViewModel {
    // MARK: - Private properties

    private let artist: Artist
    private let index: Int
    private let numberFormatter: NumberFormatter

    // MARK: - Public properties

    var name: String {
        return artist.name
    }

    var playcount: String {
        return "\(artist.playcount) plays".unlocalized
    }

    var displayIndex: String? {
        return numberFormatter.string(from: index as NSNumber)
    }

    // MARK: - Init

    init(artist: Artist, index: Int, numberFormatter: NumberFormatter) {
        self.artist = artist
        self.index = index
        self.numberFormatter = numberFormatter
    }
}
