//
//  LoadingView.swift
//  MementoFM
//
//  Created by Daniel on 15/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import SnapKit

final class LoadingView: UIView {
    // MARK: - Private properties

    private let glassView = {
        let effect = UIGlassEffect()
        effect.tintColor = UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                return UIColor.white.withAlphaComponent(0.12)
            default:
                return UIColor.black.withAlphaComponent(0.10)
            }
        }
        return UIVisualEffectView(effect: effect)
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let messageLabel = UILabel()

    // MARK: - Public properties

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 50)
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setup() {
        addGlassView()
        addActivityIndicator()
        addMessageLabel()
    }

    private func addGlassView() {
        addSubview(glassView)
        glassView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        glassView.clipsToBounds = true
    }

    private func addActivityIndicator() {
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }

        activityIndicator.startAnimating()
    }

    private func addMessageLabel() {
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(activityIndicator.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }

        messageLabel.font = .secondaryContent
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        glassView.layer.cornerRadius = glassView.frame.height / 2
    }

    // MARK: - Public methods

    func update(with message: String) {
        messageLabel.text = message
    }
}
