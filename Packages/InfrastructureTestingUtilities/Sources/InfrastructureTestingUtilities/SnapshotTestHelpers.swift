//
//  UIView+Snapshots.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import UIKit
import SnapshotTesting

public func makeAndSizeToFit<T: UIView>(width: CGFloat? = nil, _ block: (T) -> Void) -> T {
    let view = T()

    block(view)

    view.setNeedsLayout()
    view.layoutIfNeeded()
    let size = view.systemLayoutSizeFitting(CGSize(width: width ?? 1000, height: 1000))
    view.frame = CGRect(origin: .zero, size: size)
    view.frame = CGRect(x: 0, y: 0, width: width ?? size.width, height: size.height)

    return view
}

public func assertSnapshots(
    matching view: UIView,
    record: Bool = false,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    let perceptualPrecision: Float = 0.98
    assertSnapshot(
        matching: view,
        as: .image(
            perceptualPrecision: perceptualPrecision,
            traits: .init(userInterfaceStyle: .light)
        ),
        record: record,
        file: file,
        testName: testName,
        line: line
    )
    assertSnapshot(
        matching: view,
        as: .image(
            perceptualPrecision: perceptualPrecision,
            traits: .init(userInterfaceStyle: .dark)
        ),
        record: record,
        file: file,
        testName: testName,
        line: line
    )
}
