//
//  EmptyDataSetFooterView.swift
//  MementoFM
//
//  Created by Daniel on 15/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class EmptyDataSetFooterView: UITableViewHeaderFooterView {
    // MARK: - Private properties

    let messageLabel = UILabel()

    // MARK: - Init

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setup() {
        backgroundView = UIView()
        contentView.backgroundColor = .systemBackground

        contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8).priority(999)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        messageLabel.numberOfLines = 0
        messageLabel.font = .secondaryContent
        messageLabel.textColor = .darkGray
    }

    // MARK: - Public methods

    func configure(with text: String) {
        messageLabel.text = text
    }
}
