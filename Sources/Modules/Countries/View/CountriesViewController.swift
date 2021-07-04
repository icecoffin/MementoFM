//
//  CountriesViewController.swift
//  MementoFM
//
//  Created by Dani on 21.12.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

final class CountriesViewController: UIViewController {
    private let viewModel: CountriesViewModel

    private let tableView = UITableView()

    init(viewModel: CountriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addTableView()

        viewModel.loadData()
        tableView.reloadData()
    }

    private func addTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = 48
        tableView.tableFooterView = UIView()

        tableView.register(CountryCell.self)
    }
}

extension CountriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCountries
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: CountryCell.self, for: indexPath)

        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

extension CountriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        viewModel.selectCountry(at: indexPath)
    }
}
