//
//  UIFont+AppFonts.swift
//  MementoFM
//
//  Created by Daniel on 03/10/2018.
//  Copyright © 2018 icecoffin. All rights reserved.
//

import UIKit

extension UIFont {
  static var tabBarItem = UIFont.systemFont(ofSize: 10)

  static var navigationBarTitle = UIFont.systemFont(ofSize: 16, weight: .semibold)
  static var navigationBarLargeTitle = UIFont.systemFont(ofSize: 36, weight: .semibold)

  static var header = UIFont.systemFont(ofSize: 18, weight: .semibold)
  static var title = UIFont.systemFont(ofSize: 16, weight: .medium)

  static var primaryContent = UIFont.systemFont(ofSize: 16)
  static var secondaryContent = UIFont.systemFont(ofSize: 14)
  static var secondaryContentBold = UIFont.systemFont(ofSize: 14, weight: .semibold)
}
