//
//  ArtistSectionViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol ArtistSectionViewModel {
  var sectionHeaderText: String? { get }
}

extension ArtistSectionViewModel {
  var sectionHeaderText: String? {
    return nil
  }
}
