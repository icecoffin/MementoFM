//
//  SettingCell.swift
//  MementoFM
//
//  Created by Daniel on 25/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

final class SettingCell: UITableViewCell {
    // MARK: - Private properties

    private let containerView = UIView()
    private let titleLabel = UILabel()

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
        addContainerView()
        addTitleLabel()
        accessoryType = .disclosureIndicator
    }

    private func addContainerView() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(48).priority(.high)
        }
    }

    private func addTitleLabel() {
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        titleLabel.font = .primaryContent
    }

    // MARK: - Public methods

    func configure(with viewModel: SettingCellViewModel) {
        titleLabel.text = viewModel.title
    }
}
