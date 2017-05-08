//
//  Fonts.swift
//  LastFMNotifier
//
//  Created by Daniel on 05/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

enum Fonts {
  static func raleway(withSize size: CGFloat) -> UIFont {
    return font(withName: "Raleway", size: size)
  }

  static func ralewayMedium(withSize size: CGFloat) -> UIFont {
    return font(withName: "Raleway-Medium", size: size)
  }

  static func ralewayBold(withSize size: CGFloat) -> UIFont {
    return font(withName: "Raleway-Bold", size: size)
  }

  private static func font(withName name: String, size: CGFloat, fallbackToSystem: Bool = true) -> UIFont {
    if let font = UIFont(name: name, size: size) {
      return font
    }

    if fallbackToSystem {
      return UIFont.systemFont(ofSize: size)
    }

    fatalError("\(name) font is not found; did you forget to add it to the .plist file?")
  }
}
