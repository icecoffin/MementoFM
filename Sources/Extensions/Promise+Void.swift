//
//  Promise+Void.swift
//  MementoFM
//
//  Created by Daniel on 20/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

extension Promise {
  @discardableResult func noError() -> Promise<T> {
    return self
  }
}
