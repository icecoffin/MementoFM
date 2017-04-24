//
//  IgnoredTagCell.swift
//  LastFMNotifier
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class IgnoredTagCell: UITableViewCell {
  private let textField = UITextField()
  fileprivate var viewModel: IgnoredTagCellViewModel?

  fileprivate var onTextUpdate: ((String) -> Void)?

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
    textField.font = Fonts.raleway(withSize: 16)
  }

  func configure(with viewModel: IgnoredTagCellViewModel) {
    self.viewModel = viewModel
    onTextUpdate = { [unowned self] text in
      self.viewModel?.tagTextDidChange(text)
    }

    textField.text = viewModel.text
    textField.placeholder = viewModel.placeholder
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