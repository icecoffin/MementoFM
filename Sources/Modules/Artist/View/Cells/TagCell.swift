//
//  TagCell.swift
//  MementoFM
//
//  Created by Daniel on 14/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class TagCell: UICollectionViewCell {
    private struct Constants {
        static let containerViewCornerRadius: CGFloat = 6
        static let textLabelLeadingTrailingOffset: CGFloat = 8
        static let textLabelTopBottomOffset: CGFloat = 4
        static let textLabelFont: UIFont = .secondaryContent
    }

    // MARK: - Private properties

    private let containerView = UIView()
    private let textLabel = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setup() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.backgroundColor = .appPrimary
        containerView.layer.cornerRadius = Constants.containerViewCornerRadius

        containerView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Constants.textLabelTopBottomOffset).priority(999)
            make.leading.trailing.equalToSuperview().inset(Constants.textLabelLeadingTrailingOffset).priority(999)
        }
        textLabel.font = Constants.textLabelFont
        textLabel.textColor = .white
    }

    // MARK: - Public methods

    func configure(with viewModel: TagCellViewModel) {
        textLabel.text = viewModel.text
    }

    func sizeForViewModel(_ viewModel: TagCellViewModel) -> CGSize {
        let text = viewModel.text
        let attributes: [NSAttributedString.Key: Any] = [.font: Constants.textLabelFont]
        let size = text.boundingRect(
            with: CGSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            ),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).size
        return CGSize(
            width: ceil(size.width) + Constants.textLabelLeadingTrailingOffset * 2,
            height: ceil(size.height) + Constants.textLabelTopBottomOffset * 2
        )
    }
}
