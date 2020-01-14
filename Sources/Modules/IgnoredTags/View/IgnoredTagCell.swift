//
//  IgnoredTagCell.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class IgnoredTagCell: UITableViewCell {
  private let textField = UITextField()
  private var viewModel: IgnoredTagCellViewModel?

  private var onTextUpdate: ((String) -> Void)?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    contentView.addSubview(textField)
    textField.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(16)
    }

    textField.delegate = self
    textField.font = .primaryContent
  }

  func configure(with viewModel: IgnoredTagCellViewModel) {
    self.viewModel = viewModel
    onTextUpdate = { [unowned self] text in
      self.viewModel?.tagTextDidChange(text)
    }

    textField.text = viewModel.text
    textField.placeholder = viewModel.placeholder
    textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
  }

  @objc private func textFieldEditingChanged(_ textField: UITextField) {
    textField.text = textField.text?.lowercased()
  }

  override func becomeFirstResponder() -> Bool {
    return textField.becomeFirstResponder()
  }
}

extension IgnoredTagCell: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    onTextUpdate?(textField.text ?? "")
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return true
  }
}
