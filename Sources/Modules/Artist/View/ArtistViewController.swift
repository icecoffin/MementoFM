//
//  ArtistViewController.swift
//  MementoFM
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import Combine

final class ArtistViewController: UIViewController {
    // MARK: - Private properties

    private let dataSource: ArtistDataSource

    private let tableView = UITableView()
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Init

    init(dataSource: ArtistDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)

        dataSource.didUpdate
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success:
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.tableView.reloadData()
                    self?.showAlert(for: error)
                }
            })
            .store(in: &cancelBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        dataSource.registerReusableViews(in: tableView)
    }

    // MARK: - Private methods

    private func configureView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.dataSource = dataSource
        tableView.delegate = dataSource

        tableView.backgroundColor = .systemBackground
        tableView.tableFooterView = UIView()

        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionHeaderHeight = 50
        tableView.estimatedSectionFooterHeight = 50
    }
}
