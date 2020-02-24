//
//  CountryCell.swift
//  MementoFM
//
//  Created by Dani on 22.12.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

final class CountryCell: UITableViewCell {
    private let outerStackView = UIStackView()

    private let innerStackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let countLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addOuterStackView()
        addInnerStackView()
        addTitleLabel()
        addSubtitleLabel()
        addCountLabel()
    }

    private func addOuterStackView() {
        contentView.addSubview(outerStackView)
        outerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        outerStackView.axis = .horizontal
        outerStackView.spacing = 12
        outerStackView.distribution = .fill
        outerStackView.alignment = .center
        outerStackView.isLayoutMarginsRelativeArrangement = true
        outerStackView.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }

    private func addInnerStackView() {
        outerStackView.addArrangedSubview(innerStackView)

        innerStackView.axis = .vertical
        innerStackView.spacing = 2
    }

    private func addTitleLabel() {
        innerStackView.addArrangedSubview(titleLabel)

        titleLabel.font = .title
    }

    private func addSubtitleLabel() {
        innerStackView.addArrangedSubview(subtitleLabel)

        subtitleLabel.font = .subtitle
        subtitleLabel.textColor = .lightGray
    }

    private func addCountLabel() {
        outerStackView.addArrangedSubview(countLabel)
        countLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        countLabel.font = .secondaryContent
        countLabel.textColor = .darkGray
    }

    func configure(with cellViewModel: CountryCellViewModel) {
        switch cellViewModel.country {
        case .named:
            titleLabel.textColor = .black
        case .unknown:
            titleLabel.textColor = .gray
        }

        titleLabel.text = cellViewModel.country.displayName

        if let subtitle = cellViewModel.subtitle {
            subtitleLabel.isHidden = false
            subtitleLabel.text = subtitle
        } else {
            subtitleLabel.isHidden = true
        }

        countLabel.text = cellViewModel.countText
    }
}
