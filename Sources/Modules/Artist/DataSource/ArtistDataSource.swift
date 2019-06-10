//
//  ArtistDataSource.swift
//  MementoFM
//
//  Created by Daniel on 12/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class ArtistDataSource: NSObject {
  private let viewModel: ArtistViewModelProtocol
  let sectionDataSources: [ArtistSectionDataSource]

  var didUpdateData: (() -> Void)?
  var didReceiveError: ((Error) -> Void)?

  init(viewModel: ArtistViewModelProtocol) {
    self.viewModel = viewModel
    sectionDataSources = viewModel.sectionDataSources
    super.init()

    bindToViewModel()
  }

  private func bindToViewModel() {
    viewModel.didUpdateData = { [unowned self] in
      self.didUpdateData?()
    }
    viewModel.didReceiveError = { [unowned self] error in
      self.didReceiveError?(error)
    }
  }

  func registerReusableViews(in tableView: UITableView) {
    sectionDataSources.forEach { $0.registerReusableViews(in: tableView) }
  }
}

// MARK: - UITableViewDataSource
extension ArtistDataSource: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return sectionDataSources.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sectionDataSources[section].numberOfRows
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return sectionDataSources[indexPath.section].cellForRow(at: indexPath, in: tableView)
  }
}

// MARK: - UITableViewDelegate
extension ArtistDataSource: UITableViewDelegate {
  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return sectionDataSources[indexPath.section].shouldHighlightRow(at: indexPath, in: tableView)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    sectionDataSources[indexPath.section].selectRow(at: indexPath, in: tableView)
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return sectionDataSources[section].viewForHeader(inSection: section, in: tableView)
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return sectionDataSources[section].heightForHeader(inSection: section, in: tableView)
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return sectionDataSources[section].viewForFooter(inSection: section, in: tableView)
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return sectionDataSources[section].heightForFooter(inSection: section, in: tableView)
  }
}
