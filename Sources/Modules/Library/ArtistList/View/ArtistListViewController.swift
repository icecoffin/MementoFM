//
//  ArtistListViewController.swift
//  MementoFM
//
//  Created by Daniel on 12/10/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import SnapKit
import TPKeyboardAvoiding

final class ArtistListViewController: UIViewController {
    private struct Constants {
        static let estimatedRowHeight: CGFloat = 60
        static let loadingViewAnimationDuration = 0.3
        static let loadingViewAnimationDelay = 0.2
    }

    // MARK: - Private properties

    private let viewModel: ArtistListViewModel

    private let searchController: UISearchController
    private let tableView = TPKeyboardAvoidingTableView()
    private let loadingView = LoadingView()
    private let emptyDataSetView = EmptyDataSetView(text: "No artists found".unlocalized)

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

        definesPresentationContext = true

        configureSearchController()
        addTableView()
        addLoadingView()
        bindToViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.requestDataIfNeeded()
    }

    // MARK: - Private methods

    private func addTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
            make.leading.trailing.bottom.equalToSuperview()
        }

        loadingView.isHidden = true
    }

    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
    }

    private func bindToViewModel() {
        searchController.searchBar.placeholder = viewModel.searchBarPlaceholder

        viewModel.didStartLoading = { [unowned self] in
            self.showLoadingView()
        }

        viewModel.didFinishLoading = { [unowned self] in
            self.hideLoadingView()
        }

        viewModel.didUpdateData = { [unowned self] isEmpty in
            self.tableView.reloadData()
            self.tableView.backgroundView?.isHidden = !isEmpty
        }

        viewModel.didChangeStatus = { [unowned self] status in
            self.loadingView.update(with: status)
        }

        viewModel.didReceiveError = { [unowned self] error in
            self.showAlert(for: error)
            self.hideLoadingView()
        }
    }

    private func showLoadingView() {
        loadingView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(loadingView.bounds.height)
        }
        view.layoutIfNeeded()

        loadingView.isHidden = false

        UIView.animate(withDuration: Constants.loadingViewAnimationDuration,
                       delay: Constants.loadingViewAnimationDelay) {
            self.loadingView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }

    private func hideLoadingView() {
        self.loadingView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(self.loadingView.bounds.height)
        }

        UIView.animate(withDuration: Constants.loadingViewAnimationDuration,
                       delay: Constants.loadingViewAnimationDelay) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.loadingView.isHidden = true
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
