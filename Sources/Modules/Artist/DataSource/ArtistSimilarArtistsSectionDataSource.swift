//
//  ArtistSimilarArtistsSectionDataSource.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistSimilarArtistsSectionDataSource: ArtistSectionDataSource {
  private let viewModel: ArtistSimilarArtistsSectionViewModel
  private let prototypeCell = SimilarArtistCell()
  var onDidUpdateData: (() -> Void)?

  init(viewModel: ArtistSimilarArtistsSectionViewModel) {
    self.viewModel = viewModel
    viewModel.onDidUpdateCellViewModels = { [weak self] in
      self?.onDidUpdateData?()
    }
  }

  var numberOfRows: Int {
    return viewModel.numberOfSimilarArtists
  }

  func registerReusableViews(in tableView: UITableView) {
    tableView.register(SimilarArtistCell.self, forCellReuseIdentifier: SimilarArtistCell.reuseIdentifier)
    tableView.register(ArtistSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: ArtistSectionHeaderView.reuseIdentifier)
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
    let reuseIdentifier = ArtistSectionHeaderView.reuseIdentifier
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? ArtistSectionHeaderView else {
      return nil
    }

    headerView.configure(with: viewModel)
    return headerView
  }

  func heightForHeader(inSection section: Int, in tableView: UITableView) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  func viewForFooter(inSection section: Int, in tableView: UITableView) -> UITableViewHeaderFooterView? {
    if viewModel.isLoading {
      return tableView.dequeueReusableHeaderFooterView(withIdentifier: LoadingFooterView.reuseIdentifier)
    } else if !viewModel.hasSimilarArtists {
      let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: EmptyDataSetFooterView.reuseIdentifier) as? EmptyDataSetFooterView
      footer?.configure(with: viewModel.emptyDataSetText)
      return footer
    }
    return nil
  }

  func heightForFooter(inSection section: Int, in tableView: UITableView) -> CGFloat {
    if viewModel.isLoading || !viewModel.hasSimilarArtists {
      return UITableViewAutomaticDimension
    } else {
      return CGFloat.leastNormalMagnitude
    }
  }
}
