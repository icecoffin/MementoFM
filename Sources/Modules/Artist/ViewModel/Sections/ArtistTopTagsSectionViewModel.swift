//
//  ArtistTopTagsSectionViewModel.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

// MARK: - ArtistTopTagsSectionViewModelDelegate

protocol ArtistTopTagsSectionViewModelDelegate: AnyObject {
    func artistTopTagsSectionViewModel(_ viewModel: ArtistTopTagsSectionViewModel, didSelectTagWithName name: String)
}

// MARK: - ArtistTopTagsSectionViewModel

final class ArtistTopTagsSectionViewModel {
    // MARK: - Private properties

    private let artist: Artist
    private let cellViewModels: [TagCellViewModel]

    weak var delegate: ArtistTopTagsSectionViewModelDelegate?

    // MARK: - Public properties

    var numberOfTopTags: Int {
        return cellViewModels.count
    }

    var hasTags: Bool {
        return !cellViewModels.isEmpty
    }

    func cellViewModel(at indexPath: IndexPath) -> TagCellViewModel {
        return cellViewModels[indexPath.item]
    }

    var sectionHeaderText: String? {
        return "Top tags".unlocalized
    }

    var emptyDataSetText: String {
        return "There are no tags for this artist.".unlocalized
    }

    // MARK: - Init

    required init(artist: Artist) {
        self.artist = artist
        cellViewModels = artist.topTags.map({ TagCellViewModel(tag: $0) })
    }

    // MARK: - Public methods

    func selectTag(withName name: String) {
        delegate?.artistTopTagsSectionViewModel(self, didSelectTagWithName: name)
    }
}
