//
//  IgnoredTagsViewModel.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - IgnoredTagsViewModelDelegate

protocol IgnoredTagsViewModelDelegate: AnyObject {
    func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel)
}

// MARK: - IgnoredTagsViewModel

final class IgnoredTagsViewModel {
    typealias Dependencies = HasIgnoredTagService & HasArtistService

    // MARK: - Private properties

    private let dependencies: Dependencies
    private var ignoredTags: [IgnoredTag] {
        didSet {
            didUpdateTagCount?(ignoredTags.isEmpty)
        }
    }
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Public properties

    weak var delegate: IgnoredTagsViewModelDelegate?

    var didStartSavingChanges: (() -> Void)?
    var didReceiveError: ((Error) -> Void)?
    var didAddNewTag: ((IndexPath) -> Void)?
    var didUpdateTagCount: ((_ isEmpty: Bool) -> Void)?
    var didAddDefaultTags: (() -> Void)?

    var numberOfIgnoredTags: Int {
        return ignoredTags.count
    }

    // MARK: - Init

    init(dependencies: Dependencies, shouldAddDefaultTags: Bool) {
        self.dependencies = dependencies
        self.ignoredTags = dependencies.ignoredTagService.ignoredTags()
        if self.ignoredTags.isEmpty && shouldAddDefaultTags {
            addDefaultTags()
        }
    }

    // MARK: - Private methods

    private func addDefaultTags() {
        dependencies.ignoredTagService.createDefaultIgnoredTags().done {
            self.ignoredTags = self.dependencies.ignoredTagService.ignoredTags()
            self.didAddDefaultTags?()
        }.catch { error in
            self.didReceiveError?(error)
        }
    }

    // MARK: - Public methods

    func cellViewModel(at indexPath: IndexPath) -> IgnoredTagCellViewModel {
        let cellViewModel = IgnoredTagCellViewModel(tag: ignoredTags[indexPath.row])
        cellViewModel.onTextChange = { [unowned self] text in
            if indexPath.row < self.ignoredTags.count {
                let ignoredTag = self.ignoredTags[indexPath.row].updatingName(text.lowercased())
                self.ignoredTags[indexPath.row] = ignoredTag
            }
        }
        return cellViewModel
    }

    func addNewIgnoredTag() {
        let newTag = IgnoredTag(uuid: UUID().uuidString, name: "")
        ignoredTags.append(newTag)
        let newTagIndexPath = IndexPath(item: ignoredTags.count - 1, section: 0)
        didAddNewTag?(newTagIndexPath)
    }

    func deleteIgnoredTag(at indexPath: IndexPath) {
        ignoredTags.remove(at: indexPath.row)
    }

    func saveChanges() {
        didStartSavingChanges?()

        let filteredTags = ignoredTags.reduce([]) { result, ignoredTag -> [IgnoredTag] in
            if ignoredTag.name.isEmpty {
                return result
            }
            let isDuplicate = result.contains(where: { tag -> Bool in
                return ignoredTag.name == tag.name
            })
            if isDuplicate {
                return result
            }
            return result + [ignoredTag]
        }

        let calculator = ArtistTopTagsCalculator(ignoredTags: filteredTags)
        dependencies.ignoredTagService.updateIgnoredTags(filteredTags)
            .flatMap {
                return self.dependencies.artistService.calculateTopTagsForAllArtists(using: calculator)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.delegate?.ignoredTagsViewModelDidSaveChanges(self)
                case .failure(let error):
                    self.didReceiveError?(error)
                }
            }, receiveValue: { })
            .store(in: &cancelBag)
    }
}
