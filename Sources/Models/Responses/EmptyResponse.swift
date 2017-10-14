//
//  EmptyResponse.swift
//  MementoFM
//
//  Created by Daniel on 14/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct EmptyResponse {

}

extension EmptyResponse: Mappable {
  init(map: Mapper) throws {

  }
}
