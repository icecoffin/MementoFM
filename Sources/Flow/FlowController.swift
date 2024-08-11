//
//  ArtistListFlowController.swift
//  MementoFM
//
//  Created by Dani on 10.08.2024.
//  Copyright © 2024 icecoffin. All rights reserved.
//

import UIKit

protocol FlowController: UIViewController { }

extension FlowController {
    func add(child: UIViewController) {
        addChild(child)
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}
