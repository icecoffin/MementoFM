//
//  BarButtonItemHolder.swift
//  LastFMNotifier
//
//  Created by Daniel on 05/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class BlockBarButtonItem: UIBarButtonItem {
  private let actionHandler: (() -> Void)

  init(image: UIImage?, style: UIBarButtonItemStyle, actionHandler: @escaping (() -> Void)) {
    self.actionHandler = actionHandler
    super.init()

    self.image = image
    self.style = style
    self.target = self
    self.action = #selector(barButtonItemTapped(_:))
  }

  init(title: String?, style: UIBarButtonItemStyle, actionHandler: @escaping (() -> Void)) {
    self.actionHandler = actionHandler
    super.init()

    self.title = title
    self.style = style
    self.target = self
    self.action = #selector(barButtonItemTapped(_:))
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func barButtonItemTapped(_ sender: UIButton) {
    actionHandler()
  }
}
