//
//  ArtistTopTagsSectionDataSource.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistTopTagsSectionDataSource: ArtistSectionDataSource {
  private let viewModel: ArtistTopTagsSectionViewModel

  var onDidUpdateData: (() -> Void)?

  init(viewModel: ArtistTopTagsSectionViewModel) {
    self.viewModel = viewModel
  }

  var numberOfRows: Int {
    return 1
  }

  func registerReusableViews(in tableView: UITableView) {
    tableView.register(ArtistTagsCell.self, forCellReuseIdentifier: ArtistTagsCell.reuseIdentifier)
    tableView.register(ArtistTopTagsSectionHeaderView.self,
                       forHeaderFooterViewReuseIdentifier: ArtistTopTagsSectionHeaderView.reuseIdentifier)
    tableView.register(EmptyDataSetFooterView.self, forHeaderFooterViewReuseIdentifier: EmptyDataSetFooterView.reuseIdentifier)
  }

  func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistTagsCell.reuseIdentifier,
                                                   for: indexPath) as? ArtistTagsCell else {
      fatalError("ArtistTagsCell is not registered in the collection view")
    }

    cell.dataSource = self
    cell.delegate = self
    return cell
  }

  func viewForHeader(inSection: Int, in tableView: UITableView) -> UITableViewHeaderFooterView? {
    let reuseIdentifier = ArtistTopTagsSectionHeaderView.reuseIdentifier
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)
      as? ArtistTopTagsSectionHeaderView else {
      return nil
    }

    headerView.configure(with: viewModel)
    return headerView
  }

  func heightForHeader(inSection section: Int, in tableView: UITableView) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  func viewForFooter(inSection: Int, in tableView: UITableView) -> UITableViewHeaderFooterView? {
    let reuseIdentifier = EmptyDataSetFooterView.reuseIdentifier
    guard !viewModel.hasTags,
      let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)
        as? EmptyDataSetFooterView else {
      return nil
    }

    footerView.configure(with: viewModel.emptyDataSetText)
    return footerView
  }

  func heightForFooter(inSection section: Int, in tableView: UITableView) -> CGFloat {
    return viewModel.hasTags ? CGFloat.leastNormalMagnitude : UITableViewAutomaticDimension
  }
}

extension ArtistTopTagsSectionDataSource: ArtistTagsCellDataSource {
  func numberOfTopTags(in cell: ArtistTagsCell) -> Int {
    return viewModel.numberOfTopTags
  }

  func tagCellViewModel(at indexPath: IndexPath, in cell: ArtistTagsCell) -> TagCellViewModel {
    return viewModel.cellViewModel(at: indexPath)
  }
}

extension ArtistTopTagsSectionDataSource: ArtistTagsCellDelegate {
  func artistTagsCell(_ cell: ArtistTagsCell, didSelectTagAt indexPath: IndexPath) {
    let tagName = viewModel.cellViewModel(at: indexPath).name
    viewModel.selectTag(withName: tagName)
  }
}
