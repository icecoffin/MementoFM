//
//  ArtistCell.swift
//  MementoFM
//
//  Created by Daniel on 22/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

final class ArtistCell: UITableViewCell {
    // MARK: - Properties

    private let outerStackView = UIStackView()
    private let innerStackView = UIStackView()

    private let indexLabel = UILabel()
    private let verticalSeparatorView = UIView()
    private let nameLabel = UILabel()
    private let playcountLabel = UILabel()

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
    }

    private func addOuterStackView() {
        contentView.addSubview(outerStackView)
        outerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        outerStackView.axis = .horizontal
        outerStackView.alignment = .fill
        outerStackView.distribution = .fill
        outerStackView.spacing = 12
        outerStackView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        outerStackView.isLayoutMarginsRelativeArrangement = true
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        outerStackView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
    }

    private func addIndexLabel() {
        let wrapperStackView = UIStackView()
        outerStackView.addArrangedSubview(wrapperStackView)

        wrapperStackView.alignment = .top
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
        innerStackView.distribution = .fill
        innerStackView.spacing = 6
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func addNameLabel() {
        innerStackView.addArrangedSubview(nameLabel)

        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.font = .title
    }

    private func addPlaycountLabel() {
        innerStackView.addArrangedSubview(playcountLabel)

        playcountLabel.font = .secondaryContent
        playcountLabel.textColor = .gray
    }

    // MARK: - Public methods

    func configure(with viewModel: LibraryArtistCellViewModel) {
        nameLabel.text = viewModel.name
        playcountLabel.text = viewModel.playcount
        indexLabel.text = viewModel.displayIndex
    }
}
