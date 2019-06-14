//
//  ArtistTagsCell.swift
//  MementoFM
//
//  Created by Daniel on 20/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout

protocol ArtistTagsCellDataSource: class {
  func numberOfTopTags(in cell: ArtistTagsCell) -> Int
  func tagCellViewModel(at indexPath: IndexPath, in cell: ArtistTagsCell) -> TagCellViewModel
}

protocol ArtistTagsCellDelegate: class {
  func artistTagsCell(_ cell: ArtistTagsCell, didSelectTagAt indexPath: IndexPath)
}

final class ArtistTagsCell: UITableViewCell {
  private let collectionView: UICollectionView
  private let prototypeCell = TagCell()

  weak var dataSource: ArtistTagsCellDataSource? {
    didSet {
      collectionView.reloadData()
    }
  }

  weak var delegate: ArtistTagsCellDelegate?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    let layout = UICollectionViewLeftAlignedLayout()
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 8
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    contentView.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    collectionView.backgroundColor = .systemBackground
    collectionView.dataSource = self
    collectionView.delegate = self

    collectionView.isScrollEnabled = false

    collectionView.register(TagCell.self, forCellWithReuseIdentifier: TagCell.reuseIdentifier)
  }

  override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                        verticalFittingPriority: UILayoutPriority) -> CGSize {
    collectionView.layoutIfNeeded()
    return collectionView.collectionViewLayout.collectionViewContentSize
  }
}

extension ArtistTagsCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource?.numberOfTopTags(in: self) ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.reuseIdentifier,
                                                        for: indexPath) as? TagCell else {
      fatalError("TagCell is not registered in the collection view")
    }

    if let cellViewModel = dataSource?.tagCellViewModel(at: indexPath, in: self) {
      cell.configure(with: cellViewModel)
    }
    return cell
  }
}

extension ArtistTagsCell: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.artistTagsCell(self, didSelectTagAt: indexPath)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    if let cellViewModel = dataSource?.tagCellViewModel(at: indexPath, in: self) {
      return prototypeCell.sizeForViewModel(cellViewModel)
    } else {
      return .zero
    }
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    if let dataSource = dataSource, dataSource.numberOfTopTags(in: self) > 0 {
      return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    } else {
      return UIEdgeInsets(top: CGFloat.leastNormalMagnitude, left: CGFloat.leastNormalMagnitude,
                          bottom: CGFloat.leastNormalMagnitude, right: CGFloat.leastNormalMagnitude)
    }
  }
}
