//
//  TagsViewModel.swift
//  MementoFM
//
//  Created by Daniel on 16/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import CombineSchedulers

// MARK: - TagsViewModelDelegate

protocol TagsViewModelDelegate: AnyObject {
    func tagsViewModel(_ viewModel: TagsViewModel, didSelectTagWithName name: String)
}

// MARK: - TagsViewModel

final class TagsViewModel {
    typealias Dependencies = HasTagService

    // MARK: - Private properties

    private let dependencies: Dependencies
    private var allCellViewModels: [TagCellViewModel] = []
    private var filteredCellViewModels: [TagCellViewModel] = []

    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>
    private let mainScheduler: AnySchedulerOf<DispatchQueue>

    private var didUpdateDataSubject = PassthroughSubject<Bool, Never>()
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Public properties

    weak var delegate: TagsViewModelDelegate?

    var didUpdateData: AnyPublisher<Bool, Never> {
        return didUpdateDataSubject.eraseToAnyPublisher()
    }

    var numberOfTags: Int {
        return filteredCellViewModels.count
    }

    // MARK: - Init

    init(dependencies: Dependencies,
         backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler(),
         mainScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()) {
        self.dependencies = dependencies
        self.backgroundScheduler = backgroundScheduler
        self.mainScheduler = mainScheduler
    }

    // MARK: - Private methods

    private func createCellViewModels(from tags: [Tag], searchText: String?) {
        var uniqueTagNamesWithCounts = [String: Int]()
        for tag in tags {
            let name = tag.name
            if let count = uniqueTagNamesWithCounts[name] {
                uniqueTagNamesWithCounts[name] = count + 1
            } else {
                uniqueTagNamesWithCounts[name] = 1
            }
        }

        let temp: [(key: String, value: Int)] = uniqueTagNamesWithCounts.filter {
            $0.value > 1
        }
        let result = temp.sorted { value1, value2 in
            if value1.value == value2.value {
                return value1.key < value2.key
            }
            return value1.value > value2.value
        }.map {
            return Tag(name: $0.key, count: $0.value)
        }
        allCellViewModels = result.map { TagCellViewModel(tag: $0, showCount: true) }
        createFilteredCellViewModels(filter: searchText)
    }

    private func createFilteredCellViewModels(filter text: String?) {
        if let text = text, !text.isEmpty {
            filteredCellViewModels = allCellViewModels.filter({ $0.name.range(of: text, options: .caseInsensitive) != nil })
        } else {
            filteredCellViewModels = allCellViewModels
        }
    }

    // MARK: - Public methods

    func getTags(searchText: String? = nil) {
        backgroundScheduler.schedule {
            let allTopTags = self.dependencies.tagService.getAllTopTags()
            self.createCellViewModels(from: allTopTags, searchText: searchText)
            self.mainScheduler.schedule {
                self.didUpdateDataSubject.send(self.filteredCellViewModels.isEmpty)
            }
        }
    }

    func cellViewModel(at indexPath: IndexPath) -> TagCellViewModel {
        return filteredCellViewModels[indexPath.row]
    }

    func selectTag(at indexPath: IndexPath) {
        let tagName = cellViewModel(at: indexPath).name
        delegate?.tagsViewModel(self, didSelectTagWithName: tagName)
    }

    func performSearch(withText text: String?) {
        createFilteredCellViewModels(filter: text)
        didUpdateDataSubject.send(filteredCellViewModels.isEmpty)
    }

    func cancelSearch() {
        performSearch(withText: nil)
    }
}
