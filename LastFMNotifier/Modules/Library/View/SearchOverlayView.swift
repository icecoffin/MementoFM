//
//  SearchOverlayView.swift
//  LastFMNotifier
//
//  Created by Daniel on 08/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

class SearchOverlayView: UIView {
  var onTap: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    backgroundColor = UIColor.black.withAlphaComponent(0.4)
    alpha = 0.0
  }

  func show() {
    UIView.animate(withDuration: 0.3) {
      self.alpha = 1.0
    }
  }

  func hide() {
    UIView.animate(withDuration: 0.3) {
      self.alpha = 0.0
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    onTap?()
  }
}
