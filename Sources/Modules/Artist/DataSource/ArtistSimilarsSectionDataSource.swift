//
//  ArtistSimilarsSectionDataSource.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class ArtistSimilarsSectionDataSource: ArtistSectionDataSource {
    private let viewModel: ArtistSimilarsSectionViewModel

    var didUpdateData: (() -> Void)?
    var didReceiveError: ((Error) -> Void)?

    init(viewModel: ArtistSimilarsSectionViewModel) {
        self.viewModel = viewModel
        viewModel.didUpdateData = { [weak self] in
            self?.didUpdateData?()
        }
        viewModel.didReceiveError = { [weak self] error in
            self?.didReceiveError?(error)
        }
        viewModel.getSimilarArtists()
    }

    var numberOfRows: Int {
        return viewModel.numberOfSimilarArtists
    }

    func registerReusableViews(in tableView: UITableView) {
        tableView.register(SimilarArtistCell.self)
        tableView.register(ArtistSimilarsSectionHeaderView.self)
        tableView.register(EmptyDataSetFooterView.self)
        tableView.register(LoadingFooterView.self)
    }

    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: SimilarArtistCell.self, for: indexPath)

        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)

        return cell
    }

    func viewForHeader(inSection section: Int, in tableView: UITableView) -> UITableViewHeaderFooterView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(ofType: ArtistSimilarsSectionHeaderView.self)

        headerView.delegate = self
        headerView.configure(with: viewModel)

        return headerView
    }

    func heightForHeader(inSection section: Int, in tableView: UITableView) -> CGFloat {
        return UITableView.automaticDimension
    }

    func viewForFooter(inSection section: Int, in tableView: UITableView) -> UITableViewHeaderFooterView? {
        if viewModel.isLoading {
            return tableView.dequeueReusableHeaderFooterView(ofType: LoadingFooterView.self)
        } else if !viewModel.hasSimilarArtists {
            let footer = tableView.dequeueReusableHeaderFooterView(ofType: EmptyDataSetFooterView.self)
            footer.configure(with: viewModel.emptyDataSetText)
            return footer
        }
        return nil
    }

    func heightForFooter(inSection section: Int, in tableView: UITableView) -> CGFloat {
        if viewModel.isLoading || !viewModel.hasSimilarArtists {
            return UITableView.automaticDimension
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }

    func shouldHighlightRow(at indexPath: IndexPath, in tableView: UITableView) -> Bool {
        return viewModel.canSelectSimilarArtists
    }

    func selectRow(at indexPath: IndexPath, in tableView: UITableView) {
        viewModel.selectArtist(at: indexPath)
    }
}

// MARK: - ArtistSimilarsSectionHeaderViewDelegate
extension ArtistSimilarsSectionDataSource: ArtistSimilarsSectionHeaderViewDelegate {
    func artistSimilarsSectionHeaderView(_ headerView: ArtistSimilarsSectionHeaderView,
                                         didSelectSegmentWithIndex index: Int) {
        viewModel.selectTab(at: index)
    }
}
