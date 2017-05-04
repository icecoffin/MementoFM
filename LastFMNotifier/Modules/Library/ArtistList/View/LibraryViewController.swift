//
//  LibraryViewController.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/10/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import SnapKit
import TPKeyboardAvoiding

class LibraryViewController: UIViewController {
  private struct Constants {
    static let estimatedRowHeight: CGFloat = 60
  }

  fileprivate let viewModel: LibraryViewModel

  private let searchController = UISearchController(searchResultsController: nil)
  private let tableView = TPKeyboardAvoidingTableView()
  private let loadingView = LoadingView()
  private let emptyLibraryView = EmptyDataSetView(text: "No artists found".unlocalized)

  init(viewModel: LibraryViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    definesPresentationContext = true
    automaticallyAdjustsScrollViewInsets = false

    configureSearchController()
    addTableView()
    addLoadingView()
    bindToViewModel()
  }

  private func addTableView() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.top.equalTo(topLayoutGuide.snp.bottom)
    }

    tableView.register(LibraryArtistCell.self, forCellReuseIdentifier: LibraryArtistCell.reuseIdentifier)

    tableView.dataSource = self
    tableView.delegate = self

    tableView.estimatedRowHeight = Constants.estimatedRowHeight
    tableView.tableFooterView = UIView()
    tableView.tableHeaderView = searchController.searchBar

    tableView.backgroundView = emptyLibraryView
    tableView.backgroundView?.isHidden = true
  }

  private func addLoadingView() {
    view.addSubview(loadingView)
    loadingView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
    }

    loadingView.update(with: "LOADING".unlocalized)
  }

  private func configureSearchController() {
    searchController.searchBar.delegate = self
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    // Force load UISearchController's view to avoid the warning on dealloc
    _ = searchController.view
  }

  private func bindToViewModel() {
    searchController.searchBar.placeholder = viewModel.searchBarPlaceholder

    viewModel.onDidStartLoading = { [unowned self] in
      self.loadingView.isHidden = false
    }

    viewModel.onDidFinishLoading = { [unowned self] in
      self.loadingView.isHidden = true
    }

    viewModel.onDidUpdateData = { [unowned self] isEmpty in
      self.tableView.reloadData()
      self.tableView.backgroundView?.isHidden = !isEmpty
    }

    viewModel.onDidChangeStatus = { [unowned self] status in
      self.loadingView.update(with: status)
    }

    viewModel.onDidReceiveError = { [unowned self] error in
      self.showAlert(for: error)
      self.loadingView.isHidden = true
    }

    viewModel.requestData()
  }
}

// MARK: UITableViewDataSource
extension LibraryViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.itemCount
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let reuseIdentifier = LibraryArtistCell.reuseIdentifier
    guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? LibraryArtistCell else {
      fatalError("LibraryArtistCell is not registered in the table view")
    }

    let artistViewModel = viewModel.artistViewModel(at: indexPath)
    cell.configure(with: artistViewModel)

    return cell
  }
}

// MARK: UITableViewDelegate
extension LibraryViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    viewModel.selectArtist(at: indexPath)
  }
}

extension LibraryViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    viewModel.finishSearching(withText: searchController.searchBar.text ?? "")
  }
}

// MARK: UISearchBarDelegate
extension LibraryViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}
