//
//  IgnoredTagCellViewModel.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

final class IgnoredTagCellViewModel {
  private let tag: IgnoredTag

  var onTextChange: ((String) -> Void)?

  init(tag: IgnoredTag) {
    self.tag = tag
  }

  var placeholder: String {
    return "Enter tag here".unlocalized
  }

  var text: String {
    return tag.name
  }

  func tagTextDidChange(_ text: String) {
    onTextChange?(text)
  }
}
