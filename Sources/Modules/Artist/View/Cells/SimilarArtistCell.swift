//
//  SimilarArtistCell.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import Kingfisher

final class SimilarArtistCell: UITableViewCell {
    // MARK: - Properties

    private let outerStackView = UIStackView()
    private let innerStackView = UIStackView()

    private let indexLabel = UILabel()
    private let verticalSeparatorView = UIView()
    private let nameLabel = UILabel()
    private let playcountLabel = UILabel()
    private let tagsLabel = UILabel()
    private let horizontalSeparatorView = UIView()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setup() {
        addOuterStackView()
        addIndexLabel()
        addVerticalSeparatorView()

        addInnerStackView()
        addNameLabel()
        addPlaycountLabel()
        addTagsLabel()

        addHorizontalSeparatorView()
    }

    private func addOuterStackView() {
        contentView.addSubview(outerStackView)
        outerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().priority(999)
        }

        outerStackView.axis = .horizontal
        outerStackView.spacing = 12
        outerStackView.distribution = .fill
        outerStackView.alignment = .fill
        outerStackView.isLayoutMarginsRelativeArrangement = true
        outerStackView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }

    private func addIndexLabel() {
        let wrapperStackView = UIStackView()
        outerStackView.addArrangedSubview(wrapperStackView)

        wrapperStackView.alignment = .top
        wrapperStackView.distribution = .fill

        wrapperStackView.addArrangedSubview(indexLabel)
        indexLabel.snp.makeConstraints { make in
            make.width.equalTo(60)
        }

        indexLabel.textAlignment = .right
        indexLabel.font = .primaryContent
        indexLabel.textColor = .darkGray
    }

    private func addVerticalSeparatorView() {
        outerStackView.addArrangedSubview(verticalSeparatorView)
        verticalSeparatorView.snp.makeConstraints { make in
            make.width.equalTo(0.5)
        }
        verticalSeparatorView.backgroundColor = .separator
    }

    private func addInnerStackView() {
        outerStackView.addArrangedSubview(innerStackView)
        innerStackView.axis = .vertical
        innerStackView.spacing = 6
        innerStackView.distribution = .fill
    }

    private func addNameLabel() {
        innerStackView.addArrangedSubview(nameLabel)
        nameLabel.numberOfLines = 0
        nameLabel.font = .title
    }

    private func addPlaycountLabel() {
        innerStackView.addArrangedSubview(playcountLabel)
        playcountLabel.font = .secondaryContent
        playcountLabel.textColor = .gray
    }

    private func addTagsLabel() {
        innerStackView.addArrangedSubview(tagsLabel)
        tagsLabel.numberOfLines = 0
        tagsLabel.font = .secondaryContent
        tagsLabel.textColor = .darkGray
    }

    private func addHorizontalSeparatorView() {
        contentView.addSubview(horizontalSeparatorView)
        horizontalSeparatorView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        horizontalSeparatorView.backgroundColor = .separator
    }

    // MARK: - Public methods

    func configure(with viewModel: SimilarArtistCellViewModelProtocol) {
        nameLabel.text = viewModel.name
        playcountLabel.text = viewModel.playcount
        tagsLabel.attributedText = viewModel.tags
        indexLabel.text = viewModel.displayIndex
    }
}
