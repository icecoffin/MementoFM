//
//  TagsViewController.swift
//  MementoFM
//
//  Created by Daniel on 16/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout
import TPKeyboardAvoiding

final class TagsViewController: UIViewController {
  private let collectionView: TPKeyboardAvoidingCollectionView
  private let emptyDataSetView = EmptyDataSetView(text: "No tags found".unlocalized)
  private let searchController: UISearchController

  private let viewModel: TagsViewModel
  private let prototypeCell = TagCell()

  init(searchController: UISearchController, viewModel: TagsViewModel) {
    self.searchController = searchController
    let layout = UICollectionViewLeftAlignedLayout()
    layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    collectionView = TPKeyboardAvoidingCollectionView(frame: .zero, collectionViewLayout: layout)

    self.viewModel = viewModel
    viewModel.getTags()
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    definesPresentationContext = true

    configureView()
    configureSearchController()
    bindToViewModel()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    viewModel.getTags(searchText: searchController.searchBar.text)
  }

  private func configureView() {
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    collectionView.backgroundColor = .systemBackground

    collectionView.dataSource = self
    collectionView.delegate = self

    collectionView.register(TagCell.self, forCellWithReuseIdentifier: TagCell.reuseIdentifier)

    collectionView.backgroundView = emptyDataSetView
    collectionView.backgroundView?.isHidden = true
  }

  private func configureSearchController() {
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
  }

  private func bindToViewModel() {
    viewModel.didUpdateData = { [unowned self] isEmpty in
      self.collectionView.reloadData()
      self.collectionView.backgroundView?.isHidden = !isEmpty
    }
  }
}

extension TagsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfTags
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.reuseIdentifier,
                                                        for: indexPath) as? TagCell else {
      fatalError("TagCell is not registered in the collection view")
    }

    let cellViewModel = viewModel.cellViewModel(at: indexPath)
    cell.configure(with: cellViewModel)
    return cell
  }
}

extension TagsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    viewModel.selectTag(at: indexPath)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellViewModel = viewModel.cellViewModel(at: indexPath)
    return prototypeCell.sizeForViewModel(cellViewModel)
  }
}

extension TagsViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.performSearch(withText: searchText)
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    viewModel.cancelSearch()
  }
}
