//
//  IgnoredTagsViewController.swift
//  LastFMNotifier
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class IgnoredTagsViewController: UIViewController {
  fileprivate let viewModel: IgnoredTagsViewModel

  private let tableView = TPKeyboardAvoidingTableView()

  init(viewModel: IgnoredTagsViewModel) {
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

    tableView.estimatedRowHeight = 44
    tableView.allowsSelection = false
    tableView.tableFooterView = UIView()

    tableView.register(IgnoredTagCell.self, forCellReuseIdentifier: IgnoredTagCell.reuseIdentifier)

    tableView.dataSource = self
    tableView.delegate = self
  }

  private func bindToViewModel() {
    title = viewModel.title

    viewModel.onWillSaveChanges = { [unowned self] in
      self.view.endEditing(true)
    }

    viewModel.onDidAddNewTag = { [unowned self] indexPath in
      self.tableView.beginUpdates()
      self.tableView.insertRows(at: [indexPath], with: .automatic)
      self.tableView.endUpdates()
      let cell = self.tableView.cellForRow(at: indexPath)
      cell?.becomeFirstResponder()
    }
  }
}

extension IgnoredTagsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfIgnoredTags
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: IgnoredTagCell.reuseIdentifier,
                                                   for: indexPath) as? IgnoredTagCell else {
      fatalError("IgnoredTagCell is not registered in the table view")
    }

    let cellViewModel = viewModel.cellViewModel(at: indexPath)
    cell.configure(with: cellViewModel)

    return cell
  }
}

extension IgnoredTagsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      tableView.beginUpdates()
      tableView.deleteRows(at: [indexPath], with: .automatic)
      viewModel.deleteIgnoredTag(at: indexPath)
      tableView.endUpdates()
    }
  }
}
