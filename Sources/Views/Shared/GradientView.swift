//
//  GradientView.swift
//  MementoFM
//
//  Created by Dani on 11.06.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

final class GradientView: UIView {
  enum Direction {
    case horizontal
    case vertical
    case diagonal
  }

  var colors: [UIColor] = [] {
    didSet {
      updateColors()
    }
  }

  var direction: Direction = .horizontal {
    didSet {
      updateDirection()
    }
  }

  override public class var layerClass: AnyClass {
    return CAGradientLayer.self
  }

  private var gradientLayer: CAGradientLayer {
    guard let layer = layer as? CAGradientLayer else {
      fatalError("Check if layerClass is returning CAGradientLayer.self")
    }

    return layer
  }

  private func updateColors() {
    gradientLayer.colors = colors.map { $0.cgColor }
  }

  private func updateDirection() {
    switch direction {
    case .horizontal:
      gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
      gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    case .vertical:
      gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
      gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    case .diagonal:
      gradientLayer.startPoint = .zero
      gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateColors()
    updateDirection()
  }
}
