//
//  SimilarArtistCell.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import CoreUI

final class SimilarArtistCell: UITableViewCell {
    // MARK: - Properties

    private let outerStackView = UIStackView()
    private let innerStackView = UIStackView()

    private let indexLabel = UILabel()
    private let verticalSeparatorView = UIView()
    private let nameLabel = UILabel()
    private let playcountLabel = UILabel()
    private let tagsLabel = UILabel()

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
        wrapperStackView.alignment = .top
        wrapperStackView.axis = .vertical

        outerStackView.addArrangedSubview(wrapperStackView)
        wrapperStackView.snp.makeConstraints { make in
            make.width.equalTo(35)
        }

        let spacerView = UIView()
        wrapperStackView.addArrangedSubview(spacerView)
        spacerView.snp.makeConstraints { make in
            make.height.equalTo(3)
        }

        wrapperStackView.addArrangedSubview(indexLabel)
        indexLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        indexLabel.textAlignment = .right
        indexLabel.font = .subtitle
        indexLabel.textColor = .darkGray
        indexLabel.adjustsFontSizeToFitWidth = true

        wrapperStackView.addArrangedSubview(UIView())
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

    // MARK: - Public methods

    func configure(with viewModel: SimilarArtistCellViewModelProtocol) {
        nameLabel.text = viewModel.name
        playcountLabel.text = viewModel.playcount
        tagsLabel.attributedText = viewModel.tags
        indexLabel.text = viewModel.displayIndex
    }
}
