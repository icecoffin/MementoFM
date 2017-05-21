//
//  ArtistViewController.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController {
  fileprivate let dataSource: ArtistDataSource

  private let tableView = UITableView(frame: .zero, style: .grouped)

  init(dataSource: ArtistDataSource) {
    self.dataSource = dataSource
    super.init(nibName: nil, bundle: nil)

    dataSource.onDidUpdateData = { [weak self] _ in
      self?.tableView.reloadData()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
    dataSource.registerReusableViews(in: tableView)
  }

  private func configureView() {
    view.backgroundColor = .white

    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    tableView.dataSource = self
    tableView.delegate = self

    tableView.backgroundColor = .white
    tableView.separatorStyle = .none

    tableView.estimatedRowHeight = 50
    tableView.estimatedSectionHeaderHeight = 50
    tableView.estimatedSectionFooterHeight = 50
  }
}

extension ArtistViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.numberOfSections
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.numberOfItems(inSection: section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return dataSource.cellForRow(at: indexPath, in: tableView)
  }
}

extension ArtistViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return dataSource.viewForHeader(inSection: section, in: tableView)
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return dataSource.heightForHeader(inSection: section, in: tableView)
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return dataSource.viewForFooter(inSection: section, in: tableView)
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return dataSource.heightForFooter(inSection: section, in: tableView)
  }
}
