//
//  ArtistViewController.swift
//  MementoFM
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController {
  fileprivate let dataSource: ArtistDataSource

  private let tableView = UITableView()

  init(dataSource: ArtistDataSource) {
    self.dataSource = dataSource
    super.init(nibName: nil, bundle: nil)

    dataSource.onDidUpdateData = { [weak self] in
      self?.tableView.reloadData()
    }

    dataSource.onDidReceiveError = { [weak self] error in
      self?.tableView.reloadData()
      self?.showAlert(for: error)
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
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    tableView.dataSource = dataSource
    tableView.delegate = dataSource

    tableView.backgroundColor = .white
    tableView.separatorStyle = .none

    tableView.estimatedRowHeight = 80
    tableView.estimatedSectionHeaderHeight = 50
    tableView.estimatedSectionFooterHeight = 50
  }
}
