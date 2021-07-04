//
//  IgnoredTagsViewController.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

final class IgnoredTagsViewController: UIViewController {
    private let viewModel: IgnoredTagsViewModel

    private let tableView = TPKeyboardAvoidingTableView()
    private let emptyDataSetView: EmptyDataSetView

    init(viewModel: IgnoredTagsViewModel) {
        self.viewModel = viewModel

        let emptyDataSetText = "Add tags that will be ignored when calculating similar artists".unlocalized
        self.emptyDataSetView = EmptyDataSetView(text: emptyDataSetText)
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
        view.backgroundColor = .systemBackground

        addTableView()
    }

    private func addTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.estimatedRowHeight = 48
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()

        tableView.backgroundView = emptyDataSetView

        tableView.register(IgnoredTagCell.self)

        tableView.dataSource = self
        tableView.delegate = self
    }

    private func bindToViewModel() {
        viewModel.didStartSavingChanges = { [unowned self] in
            self.view.endEditing(true)
            self.tableView.isUserInteractionEnabled = false
        }

        viewModel.didFinishSavingChanges = {
            self.tableView.isUserInteractionEnabled = true
        }

        viewModel.didReceiveError = { [unowned self] error in
            self.showAlert(for: error)
        }

        viewModel.didAddNewTag = { [unowned self] indexPath in
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            self.tableView.backgroundView?.isHidden = self.viewModel.numberOfIgnoredTags != 0
            let cell = self.tableView.cellForRow(at: indexPath)
            cell?.becomeFirstResponder()
        }

        viewModel.didUpdateTagCount = { [unowned self] isEmpty in
            self.tableView.backgroundView?.isHidden = !isEmpty
        }

        viewModel.didAddDefaultTags = { [unowned self] in
            self.tableView.reloadData()
        }

        tableView.backgroundView?.isHidden = viewModel.numberOfIgnoredTags > 0
    }
}

extension IgnoredTagsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfIgnoredTags
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: IgnoredTagCell.self, for: indexPath)

        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)

        return cell
    }
}

extension IgnoredTagsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            viewModel.deleteIgnoredTag(at: indexPath)
            tableView.endUpdates()
        }
    }
}
