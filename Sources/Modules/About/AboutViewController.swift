//
//  AboutViewController.swift
//  MementoFM
//
//  Created by Daniel on 04/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
  private let textView = UITextView()

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
  }

  private func configureView() {
    view.backgroundColor = .white

    view.addSubview(textView)
    textView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(16)
    }

    textView.font = Fonts.raleway(withSize: 16)
    textView.isEditable = false
    textView.dataDetectorTypes = [.link]
    textView.text = aboutTexts().joined(separator: "\n\n")
  }

  private func aboutTexts() -> [String] {
    return [
      "Artist information, photos and tags are provided by Last.fm (https://last.fm/api/)".unlocalized,
      "Icons are taken from the Subway Icon Set (https://github.com/mariuszostrowski/subway) by Mariusz Ostrowski (https://github.com/mariuszostrowski/), provided under CC BY 4.0. (http://creativecommons.org/licenses/by/4.0/)".unlocalized
    ]
  }
}
