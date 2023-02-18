//
//  ArtistSimilarsSectionHeaderView.swift
//  MementoFM
//
//  Created by Daniel on 14/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import CoreUI

// MARK: - ArtistSimilarsSectionHeaderViewDelegate

protocol ArtistSimilarsSectionHeaderViewDelegate: AnyObject {
    func artistSimilarsSectionHeaderView(_ headerView: ArtistSimilarsSectionHeaderView,
                                         didSelectSegmentWithIndex index: Int)
}

// MARK: - ArtistSectionHeaderViewModelProtocol

protocol ArtistSectionHeaderViewModelProtocol {
    var sectionHeaderText: String? { get }
}

// MARK: - ArtistSimilarsSectionHeaderView

final class ArtistSimilarsSectionHeaderView: UITableViewHeaderFooterView {
    // MARK: - Private properties

    private let titleLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["Local".unlocalized, "Last.fm".unlocalized])

    weak var delegate: ArtistSimilarsSectionHeaderViewDelegate?

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

        addTitleLabel()
        addSegmentedControl()
    }

    private func addTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        titleLabel.numberOfLines = 0
        titleLabel.font = .header
    }

    private func addSegmentedControl() {
        contentView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8).priority(999)
        }

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }

    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        delegate?.artistSimilarsSectionHeaderView(self, didSelectSegmentWithIndex: sender.selectedSegmentIndex)
    }

    // MARK: - Public methods

    func configure(with viewModel: ArtistSectionHeaderViewModelProtocol) {
        titleLabel.text = viewModel.sectionHeaderText
    }
}
