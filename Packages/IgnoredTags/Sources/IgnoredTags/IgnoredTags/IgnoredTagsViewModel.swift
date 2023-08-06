//
//  IgnoredTagsViewModel.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import TransientModels
import SharedServicesInterface

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
            areTagsEmptySubject.send(ignoredTags.isEmpty)
        }
    }

    private let isSavingChangesSubject = PassthroughSubject<Bool, Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()
    private let didAddNewTagSubject = PassthroughSubject<IndexPath, Never>()
    private let areTagsEmptySubject = PassthroughSubject<Bool, Never>()
    private let didAddDefaultTagsSubject = PassthroughSubject<Void, Never>()

    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Public properties

    weak var delegate: IgnoredTagsViewModelDelegate?

    var isSavingChanges: AnyPublisher<Bool, Never> {
        return isSavingChangesSubject.eraseToAnyPublisher()
    }

    var error: AnyPublisher<Error, Never> {
        return errorSubject.eraseToAnyPublisher()
    }

    var didAddNewTag: AnyPublisher<IndexPath, Never> {
        return didAddNewTagSubject.eraseToAnyPublisher()
    }

    var areTagsEmpty: AnyPublisher<Bool, Never> {
        return areTagsEmptySubject.eraseToAnyPublisher()
    }

    var didAddDefaultTags: AnyPublisher<Void, Never> {
        return didAddDefaultTagsSubject.eraseToAnyPublisher()
    }

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
        return dependencies.ignoredTagService.createDefaultIgnoredTags()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }

                switch completion {
                case .finished:
                    self.ignoredTags = self.dependencies.ignoredTagService.ignoredTags()
                    self.didAddDefaultTagsSubject.send()
                case .failure(let error):
                    self.errorSubject.send(error)
                }
            }, receiveValue: { })
            .store(in: &cancelBag)
    }

    // MARK: - Public methods

    func cellViewModel(at indexPath: IndexPath) -> IgnoredTagCellViewModel {
        let cellViewModel = IgnoredTagCellViewModel(tag: ignoredTags[indexPath.row])
        cellViewModel.textChange
            .sink(receiveValue: { [unowned self] text in
                if indexPath.row < self.ignoredTags.count {
                    let ignoredTag = self.ignoredTags[indexPath.row].updatingName(text.lowercased())
                    self.ignoredTags[indexPath.row] = ignoredTag
                }
            })
            .store(in: &cancelBag)
        return cellViewModel
    }

    func addNewIgnoredTag() {
        let newTag = IgnoredTag(uuid: UUID().uuidString, name: "")
        ignoredTags.append(newTag)
        let newTagIndexPath = IndexPath(item: ignoredTags.count - 1, section: 0)
        didAddNewTagSubject.send(newTagIndexPath)
    }

    func deleteIgnoredTag(at indexPath: IndexPath) {
        ignoredTags.remove(at: indexPath.row)
    }

    func saveChanges() {
        isSavingChangesSubject.send(true)

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

        dependencies.ignoredTagService.updateIgnoredTags(filteredTags)
            .flatMap {
                return self.dependencies.artistService.calculateTopTagsForAllArtists(ignoredTags: filteredTags)
            }
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }

                self.isSavingChangesSubject.send(false)
                switch completion {
                case .finished:
                    self.delegate?.ignoredTagsViewModelDidSaveChanges(self)
                case .failure(let error):
                    self.errorSubject.send(error)
                }
            }, receiveValue: { })
            .store(in: &cancelBag)
    }
}
