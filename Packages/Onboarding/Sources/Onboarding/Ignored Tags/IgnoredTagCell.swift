//
//  IgnoredTagCell.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import CoreUI

final class IgnoredTagCell: UITableViewCell {
    // MARK: - Private properties

    private let containerView = UIView()
    private let textField = UITextField()

    private var viewModel: IgnoredTagCellViewModel?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    // MARK: - Private methods

    private func setup() {
        addContainerView()
        addTextField()
    }

    private func addContainerView() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(48).priority(.high)
        }
    }

    private func addTextField() {
        containerView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.center.equalToSuperview()
        }

        textField.delegate = self
        textField.font = .primaryContent

        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }

    // MARK: - Actions

    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        textField.text = textField.text?.lowercased()
    }

    // MARK: - Public methods

    func configure(with viewModel: IgnoredTagCellViewModel) {
        self.viewModel = viewModel

        textField.text = viewModel.text
        textField.placeholder = viewModel.placeholder
    }
}

// MARK: - UITextFieldDelegate

extension IgnoredTagCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        self.viewModel?.tagTextDidChange(text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
