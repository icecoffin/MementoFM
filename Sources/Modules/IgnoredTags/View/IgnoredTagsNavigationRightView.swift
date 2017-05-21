//
//  IgnoredTagsNavigationRightView.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class IgnoredTagsNavigationRightView: UIView {
  private let buttonSpacing: CGFloat = 12

  private let addButton = UIButton(type: .system)
  private let saveButton = UIButton(type: .system)

  var onAddTapped: (() -> Void)?
  var onSaveTapped: (() -> Void)?

  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    addSubview(addButton)
    let addIcon = #imageLiteral(resourceName: "icon_add")
    addButton.snp.makeConstraints { make in
      make.top.leading.bottom.equalToSuperview()
      make.size.equalTo(addIcon.size)
    }
    addButton.setImage(addIcon, for: .normal)
    addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)

    addSubview(saveButton)
    let saveIcon = #imageLiteral(resourceName: "icon_checkmark")
    saveButton.snp.makeConstraints { make in
      make.top.trailing.bottom.equalToSuperview()
      make.leading.equalTo(addButton.snp.trailing).offset(buttonSpacing)
      make.size.equalTo(saveIcon.size)
    }
    saveButton.setImage(saveIcon, for: .normal)
    saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
  }

  @objc private func addButtonTapped(_ sender: UIButton) {
    onAddTapped?()
  }

  @objc private func saveButtonTapped(_ sender: UIButton) {
    onSaveTapped?()
  }

  // UIBarButtonItem's customView doesn't work well with auto layout
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let icon = #imageLiteral(resourceName: "icon_add")
    return CGSize(width: icon.size.width * 2 + buttonSpacing, height: icon.size.height)
  }
}
