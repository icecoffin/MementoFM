//
//  UICollectionViewCell+DynamicSize.swift
//  MementoFM
//
//  Created by Daniel on 13/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol DynamicSizable {
  var viewForSizing: UIView { get }

  func size(constrainedToWidth width: CGFloat, renderBlock: (() -> Void)?) -> CGSize
  func size(renderBlock: (() -> Void)?) -> CGSize
}

extension UICollectionReusableView: DynamicSizable {
  var viewForSizing: UIView {
    return self
  }

  func size(constrainedToWidth width: CGFloat, renderBlock: (() -> Void)? = nil) -> CGSize {
    renderBlock?()

    bounds = CGRect(x: 0, y: 0, width: width, height: bounds.height)

    setNeedsLayout()
    layoutIfNeeded()

    let height = viewForSizing.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    return CGSize(width: width, height: height)
  }

  func size(renderBlock: (() -> Void)? = nil) -> CGSize {
    renderBlock?()

    setNeedsLayout()
    layoutIfNeeded()

    return viewForSizing.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
  }
}

extension DynamicSizable where Self: UICollectionViewCell {
  var viewForSizing: UIView {
    return contentView
  }
}
