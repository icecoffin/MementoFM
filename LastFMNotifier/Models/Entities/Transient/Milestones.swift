//
//  Milestones.swift
//  LastFMNotifier
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

enum MilestoneType {
  case initialCollection, initialArtistTags
}

struct Milestones {
  let didReceiveInitialCollection: Bool
  let didReceiveInitialArtistTags: Bool
}
