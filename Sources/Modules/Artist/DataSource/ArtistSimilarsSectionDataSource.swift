//
//  ArtistSimilarsSectionDataSource.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

enum SimilarArtistsSource: Int {
  case local = 0
  case lastFM
}

final class ArtistSimilarsSectionDataSource: ArtistSectionDataSource {
  private let viewModel: ArtistSimilarsSectionViewModel
  private let prototypeCell = SimilarArtistCell()

  var onDidUpdateData: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  init(viewModel: ArtistSimilarsSectionViewModel) {
    self.viewModel = viewModel
    viewModel.onDidUpdateData = { [weak self] in
      self?.onDidUpdateData?()
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.onDidReceiveError?(error)
    }
    viewModel.getSimilarArtists()
  }

  var numberOfRows: Int {
    return viewModel.numberOfSimilarArtists
  }

  func registerReusableViews(in tableView: UITableView) {
    tableView.register(SimilarArtistCell.self, forCellReuseIdentifier: SimilarArtistCell.reuseIdentifier)
    tableView.register(ArtistSimilarsSectionHeaderView.self,
                       forHeaderFooterViewReuseIdentifier: ArtistSimilarsSectionHeaderView.reuseIdentifier)
    tableView.register(EmptyDataSetFooterView.self, forHeaderFooterViewReuseIdentifier: EmptyDataSetFooterView.reuseIdentifier)
    tableView.register(LoadingFooterView.self, forHeaderFooterViewReuseIdentifier: LoadingFooterView.reuseIdentifier)
  }

  func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SimilarArtistCell.reuseIdentifier,
                                                   for: indexPath) as? SimilarArtistCell else {
                                                    fatalError("SimilarArtistCell is not registered in the collection view")
    }

    let cellViewModel = viewModel.cellViewModel(at: indexPath)
    cell.configure(with: cellViewModel)
    return cell
  }

  func viewForHeader(inSection section: Int, in tableView: UITableView) -> UITableViewHeaderFooterView? {
    let reuseIdentifier = ArtistSimilarsSectionHeaderView.reuseIdentifier
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)
      as? ArtistSimilarsSectionHeaderView else {
      return nil
    }

    headerView.delegate = self
    headerView.configure(with: viewModel)
    return headerView
  }

  func heightForHeader(inSection section: Int, in tableView: UITableView) -> CGFloat {
    return UITableView.automaticDimension
  }

  func viewForFooter(inSection section: Int, in tableView: UITableView) -> UITableViewHeaderFooterView? {
    if viewModel.isLoading {
      return tableView.dequeueReusableHeaderFooterView(withIdentifier: LoadingFooterView.reuseIdentifier)
    } else if !viewModel.hasSimilarArtists {
      let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: EmptyDataSetFooterView.reuseIdentifier)
        as? EmptyDataSetFooterView
      footer?.configure(with: viewModel.emptyDataSetText)
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
    return true
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
