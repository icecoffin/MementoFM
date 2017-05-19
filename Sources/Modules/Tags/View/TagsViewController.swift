//
//  TagsViewController.swift
//  LastFMNotifier
//
//  Created by Daniel on 16/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout

class TagsViewController: UIViewController {
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLeftAlignedLayout())

  fileprivate let viewModel: TagsViewModel
  fileprivate let prototypeCell = TagCell()

  init(viewModel: TagsViewModel) {
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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    viewModel.getTags()
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
  }

  private func bindToViewModel() {
    viewModel.onDidUpdateData = { [unowned self] in
      self.collectionView.reloadData()
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

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
  }
}
