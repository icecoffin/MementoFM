//
//  LibraryViewController.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/10/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import SnapKit

// TODO: rework search (use UISearchController)

class LibraryViewController: UIViewController {
  private struct Constants {
    static let estimatedRowHeight: CGFloat = 60
    static let searchBarHeight: CGFloat = 44
  }

  fileprivate let viewModel: LibraryViewModel

  private let searchBar = UISearchBar()
  private let tableView = UITableView()
  private let loadingView = LoadingView()
  fileprivate let overlayView = SearchOverlayView()

  init(viewModel: LibraryViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    addTableView()
    addLoadingView()
    bindToViewModel()

    requestData()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    overlayView.snp.updateConstraints { make in
      make.top.equalToSuperview().offset(-tableView.contentOffset.y + Constants.searchBarHeight)
    }
  }

  private func addTableView() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    tableView.register(LibraryArtistCell.self, forCellReuseIdentifier: LibraryArtistCell.reuseIdentifier)

    tableView.dataSource = self
    tableView.delegate = self

    tableView.estimatedRowHeight = Constants.estimatedRowHeight
    tableView.tableFooterView = UIView()

    addSearchBar()
    addOverlayView()
  }

  private func addSearchBar() {
    searchBar.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.searchBarHeight)

    searchBar.isTranslucent = false
    searchBar.barTintColor = .groupTableViewBackground
    searchBar.backgroundImage = UIImage()
    searchBar.delegate = self
    searchBar.enablesReturnKeyAutomatically = false

    tableView.tableHeaderView = searchBar
  }

  private func addOverlayView() {
    view.addSubview(overlayView)
    overlayView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.top.equalToSuperview().offset(-tableView.contentOffset.y + Constants.searchBarHeight)
    }

    overlayView.onTap = { [unowned self] in
      self.overlayView.hide()
      self.viewModel.cancelSearching()
      self.searchBar.resignFirstResponder()
    }
  }

  private func addLoadingView() {
    view.addSubview(loadingView)
    loadingView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  private func bindToViewModel() {
    title = viewModel.title
    searchBar.placeholder = viewModel.searchBarPlaceholder

    viewModel.onDidStartLoading = { [unowned self] in
      self.loadingView.isHidden = false
    }

    viewModel.onDidFinishLoading = { [unowned self] in
      self.loadingView.isHidden = true
      self.tableView.reloadData()
    }

    viewModel.onError = { [unowned self] error in
      self.showAlert(for: error)
      self.loadingView.isHidden = true
    }

    viewModel.onSearchTextUpdate = { [unowned self] text in
      self.searchBar.text = text
    }
  }

  private func requestData() {
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

// MARK: UISearchBarDelegate
extension LibraryViewController: UISearchBarDelegate {

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    overlayView.show()
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.searchTextDidChange(searchText)
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    viewModel.finishSearching(withText: searchBar.text ?? "")
    overlayView.hide()
    searchBar.resignFirstResponder()
  }
}
