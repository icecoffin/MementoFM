//
//  ArtistTopTagsSectionDataSource.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

// MARK: - ArtistTopTagsSectionDataSource

final class ArtistTopTagsSectionDataSource: ArtistSectionDataSource {
    // MARK: - Private properties

    private let viewModel: ArtistTopTagsSectionViewModel

    // MARK: - Public properties

    var didUpdateData: (() -> Void)?

    var numberOfRows: Int {
        return 1
    }

    // MARK: - Init

    init(viewModel: ArtistTopTagsSectionViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Public methods

    func registerReusableViews(in tableView: UITableView) {
        tableView.register(ArtistTagsCell.self)
        tableView.register(ArtistTopTagsSectionHeaderView.self)
        tableView.register(EmptyDataSetFooterView.self)
    }

    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: ArtistTagsCell.self, for: indexPath)

        cell.dataSource = self
        cell.delegate = self

        return cell
    }

    func viewForHeader(inSection: Int, in tableView: UITableView) -> UITableViewHeaderFooterView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(ofType: ArtistTopTagsSectionHeaderView.self)

        headerView.configure(with: viewModel)

        return headerView
    }

    func heightForHeader(inSection section: Int, in tableView: UITableView) -> CGFloat {
        return UITableView.automaticDimension
    }

    func viewForFooter(inSection: Int, in tableView: UITableView) -> UITableViewHeaderFooterView? {
        guard !viewModel.hasTags else { return nil }

        let footerView = tableView.dequeueReusableHeaderFooterView(ofType: EmptyDataSetFooterView.self)

        footerView.configure(with: viewModel.emptyDataSetText)

        return footerView
    }

    func heightForFooter(inSection section: Int, in tableView: UITableView) -> CGFloat {
        return viewModel.hasTags ? CGFloat.leastNormalMagnitude : UITableView.automaticDimension
    }
}

// MARK: - ArtistTagsCellDataSource

extension ArtistTopTagsSectionDataSource: ArtistTagsCellDataSource {
    func numberOfTopTags(in cell: ArtistTagsCell) -> Int {
        return viewModel.numberOfTopTags
    }

    func tagCellViewModel(at indexPath: IndexPath, in cell: ArtistTagsCell) -> TagCellViewModel {
        return viewModel.cellViewModel(at: indexPath)
    }
}

// MARK: - ArtistTagsCellDelegate

extension ArtistTopTagsSectionDataSource: ArtistTagsCellDelegate {
    func artistTagsCell(_ cell: ArtistTagsCell, didSelectTagAt indexPath: IndexPath) {
        let tagName = viewModel.cellViewModel(at: indexPath).name
        viewModel.selectTag(withName: tagName)
    }
}
