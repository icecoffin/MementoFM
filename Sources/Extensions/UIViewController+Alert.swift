//
//  UIViewController+Alert.swift
//  MementoFM
//
//  Created by Daniel on 01/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

extension UIViewController {
  func showAlert(for error: Error) {
    let title = ErrorConverter.displayMessage(for: error)
    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    alert.addAction(okAction())
    present(alert, animated: true, completion: nil)
  }

  private func okAction() -> UIAlertAction {
    return UIAlertAction(title: "OK".unlocalized, style: .default, handler: nil)
  }
}
