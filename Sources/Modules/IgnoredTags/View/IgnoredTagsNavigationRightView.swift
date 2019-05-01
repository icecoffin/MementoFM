//
//  IgnoredTagsNavigationRightView.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class IgnoredTagsNavigationRightView: UIView {
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
    let addIcon = R.image.iconAdd()
    addButton.snp.makeConstraints { make in
      make.top.leading.bottom.equalToSuperview()
      make.size.equalTo(addIcon?.size ?? .zero)
    }
    addButton.setImage(addIcon, for: .normal)
    addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)

    addSubview(saveButton)
    let saveIcon = R.image.iconCheckmark()
    saveButton.snp.makeConstraints { make in
      make.top.trailing.bottom.equalToSuperview()
      make.leading.equalTo(addButton.snp.trailing).offset(buttonSpacing)
      make.size.equalTo(saveIcon?.size ?? .zero)
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
    let addIconSize = R.image.iconAdd()?.size ?? .zero
    let saveIconSize = R.image.iconCheckmark()?.size ?? .zero
    return CGSize(width: addIconSize.width + saveIconSize.width + buttonSpacing,
                  height: max(addIconSize.height, saveIconSize.height))
  }
}
