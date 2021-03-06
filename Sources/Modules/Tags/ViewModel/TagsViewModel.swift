//
//  TagsViewModel.swift
//  MementoFM
//
//  Created by Daniel on 16/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol TagsViewModelDelegate: AnyObject {
    func tagsViewModel(_ viewModel: TagsViewModel, didSelectTagWithName name: String)
}

final class TagsViewModel {
    typealias Dependencies = HasTagService

    private let dependencies: Dependencies
    private var allCellViewModels: [TagCellViewModel] = []
    private var filteredCellViewModels: [TagCellViewModel] = []

    weak var delegate: TagsViewModelDelegate?

    var didUpdateData: ((_ isEmpty: Bool) -> Void)?

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func getTags(searchText: String? = nil,
                 backgroundDispatcher: Dispatcher = AsyncDispatcher.global,
                 mainDispatcher: Dispatcher = AsyncDispatcher.main) {
        backgroundDispatcher.dispatch {
            let allTopTags = self.dependencies.tagService.getAllTopTags()
            self.createCellViewModels(from: allTopTags, searchText: searchText)
        }.done(on: mainDispatcher.queue) {
            self.didUpdateData?(self.filteredCellViewModels.isEmpty)
        }
    }

    var numberOfTags: Int {
        return filteredCellViewModels.count
    }

    func cellViewModel(at indexPath: IndexPath) -> TagCellViewModel {
        return filteredCellViewModels[indexPath.row]
    }

    func selectTag(at indexPath: IndexPath) {
        let tagName = cellViewModel(at: indexPath).name
        delegate?.tagsViewModel(self, didSelectTagWithName: tagName)
    }

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
        allCellViewModels = result.map { TagCellViewModel(tag: $0) }
        createFilteredCellViewModels(filter: searchText)
    }

    private func createFilteredCellViewModels(filter text: String?) {
        if let text = text, !text.isEmpty {
            filteredCellViewModels = allCellViewModels.filter({ $0.name.range(of: text, options: .caseInsensitive) != nil })
        } else {
            filteredCellViewModels = allCellViewModels
        }
    }

    func performSearch(withText text: String?) {
        createFilteredCellViewModels(filter: text)
        didUpdateData?(filteredCellViewModels.isEmpty)
    }

    func cancelSearch() {
        performSearch(withText: nil)
    }
}
