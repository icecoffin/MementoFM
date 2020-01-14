//
//  HUD.swift
//  MementoFM
//
//  Created by Daniel on 14/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import SVProgressHUD

enum HUD {
    static func show() {
        SVProgressHUD.show()
    }

    static func dismiss() {
        SVProgressHUD.dismiss()
    }
}
