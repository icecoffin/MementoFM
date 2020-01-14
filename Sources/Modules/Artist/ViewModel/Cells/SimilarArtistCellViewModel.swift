//
//  SimilarArtistCellViewModel.swift
//  MementoFM
//
//  Created by Daniel on 14/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import UIKit.UIFont

protocol SimilarArtistCellViewModelProtocol {
    var name: String { get }
    var playcount: String { get }
    var tags: NSAttributedString { get }
    var displayIndex: String { get }
}

final class SimilarArtistCellViewModel: SimilarArtistCellViewModelProtocol {
    let artist: Artist
    private let commonTags: [String]
    private let index: Int

    init(artist: Artist, commonTags: [String], index: Int) {
        self.artist = artist
        self.commonTags = commonTags
        self.index = index
    }

    var name: String {
        return artist.name
    }

    var playcount: String {
        return "\(artist.playcount) plays".unlocalized
    }

    var tags: NSAttributedString {
        return artist.topTags.map({ tag in
            let name = tag.name
            if commonTags.contains(name) {
                return NSAttributedString(string: name, attributes: [.font: UIFont.secondaryContentBold])
            } else {
                return NSAttributedString(string: name)
            }
        }).joined(separator: ", ")
    }

    var displayIndex: String {
        return String(index)
    }
}
