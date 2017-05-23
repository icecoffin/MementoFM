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

class TagsViewController: UIViewController {
  private let collectionView: TPKeyboardAvoidingCollectionView
  private let emptyDataSetView = EmptyDataSetView(text: "No tags found".unlocalized)
  fileprivate let searchController = UISearchController(searchResultsController: nil)

  fileprivate let viewModel: TagsViewModel
  fileprivate let prototypeCell = TagCell()

  init(viewModel: TagsViewModel) {
    let layout = UICollectionViewLeftAlignedLayout()
    layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    collectionView = TPKeyboardAvoidingCollectionView(frame: .zero, collectionViewLayout: layout)

    self.viewModel = viewModel
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
    collectionView.backgroundColor = .white

    collectionView.dataSource = self
    collectionView.delegate = self

    collectionView.register(TagCell.self, forCellWithReuseIdentifier: TagCell.reuseIdentifier)
    collectionView.register(TagsSearchHeaderView.self,
                            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                            withReuseIdentifier: TagsSearchHeaderView.reuseIdentifier)

    collectionView.backgroundView = emptyDataSetView
    collectionView.backgroundView?.isHidden = true
  }

  private func configureSearchController() {
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
  }

  private func bindToViewModel() {
    viewModel.onDidUpdateData = { [unowned self] isEmpty in
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
    // Prevents unwanted animations in LibraryViewController
    DispatchQueue.main.async {
      self.viewModel.selectTag(at: indexPath)
    }
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellViewModel = viewModel.cellViewModel(at: indexPath)
    return prototypeCell.sizeForViewModel(cellViewModel)
  }

  func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath) -> UICollectionReusableView {
    guard kind == UICollectionElementKindSectionHeader else {
      fatalError("Unknown supplementary view kind")
    }

    let reuseIdentifier = TagsSearchHeaderView.reuseIdentifier
    guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: reuseIdentifier,
                                                                           for: indexPath) as? TagsSearchHeaderView else {
      fatalError("TagsSearchHeaderView is not registered in the collectionView")
    }

    headerView.addSearchBar(searchController.searchBar)
    return headerView
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
    return searchController.searchBar.frame.size
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
