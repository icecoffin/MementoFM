//
//  ArtistViewController.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout

class ArtistViewController: UIViewController {
  fileprivate let dataSource: ArtistDataSource

  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLeftAlignedLayout())

  init(dataSource: ArtistDataSource) {
    self.dataSource = dataSource
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
    dataSource.registerReusableViews(in: collectionView)
  }

  private func configureView() {
    view.backgroundColor = .white
    collectionView.backgroundColor = .white

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    collectionView.dataSource = self
    collectionView.delegate = self
  }
}

extension ArtistViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return dataSource.numberOfSections
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.numberOfItems(inSection: section)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return dataSource.cellForItem(at: indexPath, in: collectionView)
  }
}

extension ArtistViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath) -> UICollectionReusableView {
    return dataSource.supplementaryView(ofKind: kind, at: indexPath, in: collectionView)
  }
}

extension ArtistViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return dataSource.sizeForItem(at: indexPath, in: collectionView)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
    return dataSource.sizeForHeader(inSection: section, in: collectionView)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return dataSource.insetForSection(at: section, in: collectionView)
  }
}
