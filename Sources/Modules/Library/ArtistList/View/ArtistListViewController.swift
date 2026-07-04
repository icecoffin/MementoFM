//
//  ArtistListViewController.swift
//  MementoFM
//
//  Created by Daniel on 12/10/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import SnapKit
import Combine

final class ArtistListViewController: UIViewController {
    private struct Constants {
        static let estimatedRowHeight: CGFloat = 60
        static let loadingViewAnimationDuration = 0.3
        static let loadingViewAnimationDelay = 0.2
    }

    // MARK: - Private properties

    private let viewModel: ArtistListViewModel
    private var cancelBag = Set<AnyCancellable>()

    private let searchController: UISearchController
    private let tableView = UITableView()
    private let loadingView = LoadingView()
    private let emptyDataSetView = EmptyDataSetView(text: "No artists found".unlocalized)

    private var syncTask: Task<Void, Never>?

    // MARK: - Init

    init(searchController: UISearchController, viewModel: ArtistListViewModel) {
        self.searchController = searchController
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSearchController()
        addTableView()
        addLoadingView()
        bindToViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        syncTask?.cancel()
        syncTask = Task {
            await viewModel.requestDataIfNeeded()
        }
    }

    // MARK: - Private methods

    private func addTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }

        tableView.register(ArtistCell.self)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.tableFooterView = UIView()

        tableView.backgroundView = emptyDataSetView
        tableView.backgroundView?.isHidden = true
    }

    private func addLoadingView() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.snp.bottomMargin).inset(8)
        }

        loadingView.alpha = 0.0
    }

    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
    }

    private func bindToViewModel() {
        searchController.searchBar.placeholder = viewModel.searchBarPlaceholder

        viewModel.isLoading
            .sink(receiveValue: { [unowned self] isLoading in
                if isLoading {
                    self.showLoadingView()
                } else {
                    self.hideLoadingView()
                }
            })
            .store(in: &cancelBag)

        viewModel.didUpdate
            .sink { [unowned self] result in
                switch result {
                case .success(let isEmpty):
                    self.tableView.reloadData()
                    self.tableView.backgroundView?.isHidden = !isEmpty
                case .failure(let error):
                    self.showAlert(for: error)
                }
            }
            .store(in: &cancelBag)

        viewModel.status
            .sink(receiveValue: { [unowned self] status in
                self.loadingView.update(with: status)
            })
            .store(in: &cancelBag)
    }

    private func showLoadingView() {
        UIView.animate(
            withDuration: Constants.loadingViewAnimationDuration,
            delay: Constants.loadingViewAnimationDelay
        ) {
            self.loadingView.alpha = 1.0
        }
    }

    private func hideLoadingView() {
        UIView.animate(
            withDuration: Constants.loadingViewAnimationDuration,
            delay: Constants.loadingViewAnimationDelay
        ) {
            self.loadingView.alpha = 0.0
        }
    }
}

// MARK: - UITableViewDataSource

extension ArtistListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: ArtistCell.self, for: indexPath)

        let artistViewModel = viewModel.artistViewModel(at: indexPath)
        cell.configure(with: artistViewModel)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ArtistListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        viewModel.selectArtist(at: indexPath)
    }
}

// MARK: - UISearchResultsUpdating

extension ArtistListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.performSearch(withText: searchController.searchBar.text ?? "")
    }
}
