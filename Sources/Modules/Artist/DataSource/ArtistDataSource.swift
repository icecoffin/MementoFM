//
//  ArtistDataSource.swift
//  MementoFM
//
//  Created by Daniel on 12/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistDataSource {
  private let viewModel: ArtistViewModelProtocol
  let sectionDataSources: [ArtistSectionDataSource]

  var onDidUpdateData: ((_ section: Int) -> Void)?

  init(viewModel: ArtistViewModelProtocol) {
    self.viewModel = viewModel
    sectionDataSources = viewModel.sectionDataSources
    sectionDataSources.enumerated().forEach { offset, sectionDataSource in
      sectionDataSource.onDidUpdateData = { [weak self] in
        self?.onDidUpdateData?(offset)
      }
    }
  }

  func registerReusableViews(in tableView: UITableView) {
    sectionDataSources.forEach { $0.registerReusableViews(in: tableView) }
  }

  var numberOfSections: Int {
    return sectionDataSources.count
  }

  func numberOfItems(inSection section: Int) -> Int {
    return sectionDataSources[section].numberOfRows
  }

  func shouldHighlightRow(at indexPath: IndexPath, in tableView: UITableView) -> Bool {
    return sectionDataSources[indexPath.section].shouldHighlightRow(at: indexPath, in: tableView)
  }

  func selectRow(at indexPath: IndexPath, in tableView: UITableView) {
    sectionDataSources[indexPath.section].selectRow(at: indexPath, in: tableView)
  }

  func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
    return sectionDataSources[indexPath.section].cellForRow(at: indexPath, in: tableView)
  }

  func viewForHeader(inSection section: Int, in tableView: UITableView) -> UIView? {
    return sectionDataSources[section].viewForHeader(inSection: section, in: tableView)
  }

  func heightForHeader(inSection section: Int, in tableView: UITableView) -> CGFloat {
    return sectionDataSources[section].heightForHeader(inSection: section, in: tableView)
  }

  func viewForFooter(inSection section: Int, in tableView: UITableView) -> UIView? {
    return sectionDataSources[section].viewForFooter(inSection: section, in: tableView)
  }

  func heightForFooter(inSection section: Int, in tableView: UITableView) -> CGFloat {
    return sectionDataSources[section].heightForFooter(inSection: section, in: tableView)
  }
}
