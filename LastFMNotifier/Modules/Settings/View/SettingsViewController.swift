//
//  SettingsViewController.swift
//  LastFMNotifier
//
//  Created by Daniel on 16/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  fileprivate let viewModel: SettingsViewModel

  private let tableView = UITableView()

  init(viewModel: SettingsViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
    bindToViewModel()
  }

  private func configureView() {
    addTableView()
  }

  private func addTableView() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    tableView.dataSource = self
    tableView.delegate = self

    tableView.estimatedRowHeight = 60
    tableView.tableFooterView = UIView()

    tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.reuseIdentifier)
  }

  private func bindToViewModel() {
    title = viewModel.title
  }
}

extension SettingsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.itemCount
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseIdentifier, for: indexPath) as? SettingCell else {
      return UITableViewCell()
    }

    let cellViewModel = viewModel.cellViewModel(at: indexPath.row)
    cell.configure(with: cellViewModel)

    return cell
  }
}

extension SettingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    viewModel.handleTap(at: indexPath.row)
  }
}
