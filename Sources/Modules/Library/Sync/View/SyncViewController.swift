//
//  SyncViewController.swift
//  MementoFM
//
//  Created by Daniel on 30/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class SyncViewController: UIViewController {
  private let viewModel: SyncViewModel

  private let progressView = SyncProgressView()
  private let errorView = SyncErrorView()

  init(viewModel: SyncViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
    bindToViewModel()
  }

  private func configureView() {
    view.backgroundColor = .white
    addProgressView()
    addErrorView()
  }

  private func addProgressView() {
    view.addSubview(progressView)
    progressView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(240)
      make.leading.trailing.equalToSuperview().inset(16)
    }
  }

  private func addErrorView() {
    view.addSubview(errorView)
    errorView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(240)
      make.leading.trailing.equalToSuperview().inset(16)
    }
    errorView.isHidden = true
    errorView.didTapRetry = { [unowned self] in
      self.errorView.isHidden = true
      self.progressView.isHidden = false
      self.viewModel.syncLibrary()
    }
  }

  private func bindToViewModel() {
    viewModel.didReceiveError = { [unowned self] error in
      self.progressView.isHidden = true
      self.errorView.isHidden = false
      self.errorView.updateErrorDescription(ErrorConverter.displayMessage(for: error))
    }

    viewModel.didChangeStatus = { [unowned self] status in
      self.progressView.updateStatus(status)
    }

    viewModel.syncLibrary()
  }
}

private class SyncProgressView: UIView {
  private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
  private let statusLabel = UILabel()

  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    addActivityIndicator()
    addStatusLabel()
  }

  private func addActivityIndicator() {
    addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.centerX.top.equalToSuperview()
    }
    activityIndicator.color = .black
    activityIndicator.startAnimating()
  }

  private func addStatusLabel() {
    addSubview(statusLabel)
    statusLabel.snp.makeConstraints { make in
      make.top.equalTo(activityIndicator.snp.bottom).offset(16)
      make.leading.trailing.bottom.equalToSuperview()
    }

    statusLabel.numberOfLines = 0
    statusLabel.textAlignment = .center
    statusLabel.font = .raleway(withSize: 16)
  }

  func updateStatus(_ newStatus: String) {
    statusLabel.text = newStatus
  }
}

private class SyncErrorView: UIView {
  private let errorLabel = UILabel()
  private let descriptionLabel = UILabel()
  private let retryButton = UIButton(type: .system)

  var didTapRetry: (() -> Void)?

  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    addErrorLabel()
    addDescriptionLabel()
    addRetryButton()
  }

  private func addErrorLabel() {
    addSubview(errorLabel)
    errorLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }

    errorLabel.text = "An error occured:".unlocalized
    errorLabel.textAlignment = .center
    errorLabel.font = .raleway(withSize: 16)
  }

  private func addDescriptionLabel() {
    addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(errorLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview()
    }

    descriptionLabel.numberOfLines = 0
    descriptionLabel.textAlignment = .center
    descriptionLabel.font = .raleway(withSize: 16)
  }

  private func addRetryButton() {
    addSubview(retryButton)
    retryButton.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
      make.centerX.bottom.equalToSuperview()
      make.width.equalTo(120)
      make.height.equalTo(40)
    }

    retryButton.addTarget(self, action: #selector(retryButtonTapped(_:)), for: .touchUpInside)
    retryButton.setTitle("Retry".unlocalized, for: .normal)
    retryButton.backgroundColor = .appPrimary
    retryButton.setTitleColor(UIColor.white, for: .normal)
    retryButton.titleLabel?.font = .ralewayBold(withSize: 18)
    retryButton.layer.cornerRadius = 6
  }

  func updateErrorDescription(_ description: String) {
    descriptionLabel.text = description
  }

  @objc private func retryButtonTapped(_ sender: UIButton) {
    didTapRetry?()
  }
}
