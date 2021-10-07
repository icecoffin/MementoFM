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

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
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
        addBlurView()
        addActivityIndicator()
        addMessageLabel()
    }

    private func addBlurView() {
        addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addActivityIndicator() {
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }

        activityIndicator.color = .white
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
        messageLabel.textColor = .white
    }

    // MARK: - Public methods

    func update(with message: String) {
        messageLabel.text = message
    }
}
