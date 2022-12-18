//
//  ArtistTopTagsSectionHeaderView.swift
//  MementoFM
//
//  Created by Daniel on 13/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class ArtistTopTagsSectionHeaderView: UITableViewHeaderFooterView {
    // MARK: - Private properties

    private let titleLabel = UILabel()

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
        contentView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8).priority(999)
        }

        titleLabel.font = .header
    }

    // MARK: - Public methods

    func configure(with viewModel: ArtistSectionHeaderViewModelProtocol) {
        titleLabel.text = viewModel.sectionHeaderText
    }
}
