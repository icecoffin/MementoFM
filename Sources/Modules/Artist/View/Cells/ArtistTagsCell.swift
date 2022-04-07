//
//  ArtistTagsCell.swift
//  MementoFM
//
//  Created by Daniel on 20/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

// MARK: - ArtistTagsCellDataSource

protocol ArtistTagsCellDataSource: AnyObject {
    func numberOfTopTags(in cell: ArtistTagsCell) -> Int
    func tagCellViewModel(at indexPath: IndexPath, in cell: ArtistTagsCell) -> TagCellViewModel
}

// MARK: - ArtistTagsCellDelegate

protocol ArtistTagsCellDelegate: AnyObject {
    func artistTagsCell(_ cell: ArtistTagsCell, didSelectTagAt indexPath: IndexPath)
}

// MARK: - ArtistTagsCell

final class ArtistTagsCell: UITableViewCell {
    // MARK: - Private properties

    private let collectionView: UICollectionView
    private let prototypeCell = TagCell()

    weak var dataSource: ArtistTagsCellDataSource? {
        didSet {
            collectionView.reloadData()
        }
    }

    weak var delegate: ArtistTagsCellDelegate?

    // MARK: - Init

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

    // MARK: - Private methods

    private func setup() {
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.isScrollEnabled = false

        collectionView.register(TagCell.self)
    }

    // MARK: - Overrides

    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        collectionView.layoutIfNeeded()
        return collectionView.collectionViewLayout.collectionViewContentSize
    }
}

// MARK: - UICollectionViewDataSource

extension ArtistTagsCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfTopTags(in: self) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: TagCell.self, for: indexPath)

        if let cellViewModel = dataSource?.tagCellViewModel(at: indexPath, in: self) {
            cell.configure(with: cellViewModel)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

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
