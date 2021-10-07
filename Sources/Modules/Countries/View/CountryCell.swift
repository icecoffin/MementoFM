//
//  CountryCell.swift
//  MementoFM
//
//  Created by Dani on 22.12.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

final class CountryCell: UITableViewCell {
    // MARK: - Private properties

    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setup() {
        addStackView()
        addTitleLabel()
        addCountLabel()
    }

    private func addStackView() {
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    private func addTitleLabel() {
        stackView.addArrangedSubview(titleLabel)

        titleLabel.font = .title
    }

    private func addCountLabel() {
        stackView.addArrangedSubview(countLabel)
        countLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        countLabel.font = .secondaryContent
        countLabel.textColor = .darkGray
    }

    // MARK: - Public methods

    func configure(with cellViewModel: CountryCellViewModel) {
        switch cellViewModel.country {
        case .named:
            titleLabel.textColor = .black
        case .unknown:
            titleLabel.textColor = .gray
        }

        titleLabel.text = cellViewModel.country.displayName
        countLabel.text = cellViewModel.countText
    }
}
