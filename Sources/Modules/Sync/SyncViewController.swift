//
//  SyncViewController.swift
//  MementoFM
//
//  Created by Daniel on 30/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import Combine
import CoreUI

// MARK: - SyncViewController

final class SyncViewController: UIViewController {
    // MARK: - Private properties

    private let viewModel: SyncViewModel

    private let progressView = SyncProgressView()
    private let errorView = SyncErrorView()

    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Init

    init(viewModel: SyncViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        bindToViewModel()
    }

    // MARK: - Private methods

    private func configureView() {
        view.backgroundColor = .systemBackground
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
        errorView.didTapRetry
            .sink(receiveValue: { [unowned self] in
                self.errorView.isHidden = true
                self.progressView.isHidden = false
                self.viewModel.syncLibrary()
            })
            .store(in: &cancelBag)
    }

    private func bindToViewModel() {
        viewModel.error
            .sink { [unowned self] error in
                self.progressView.isHidden = true
                self.errorView.isHidden = false
                self.errorView.updateErrorDescription(error.localizedDescription)
            }
            .store(in: &cancelBag)

        viewModel.status
            .sink(receiveValue: { [unowned self] status in
                self.progressView.updateStatus(status)
            })
            .store(in: &cancelBag)

        viewModel.syncLibrary()
    }
}

// MARK: - SyncProgressView

private final class SyncProgressView: UIView {
    // MARK: - Private properties

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let statusLabel = UILabel()

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
        statusLabel.font = .primaryContent
    }

    // MARK: - Public methods

    func updateStatus(_ newStatus: String) {
        statusLabel.text = newStatus
    }
}

// MARK: - SyncErrorView

private final class SyncErrorView: UIView {
    // MARK: - Private properties

    private let errorLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    private let didTapRetrySubject = PassthroughSubject<Void, Never>()

    // MARK: - Public properties

    var didTapRetry: AnyPublisher<Void, Never> {
        return didTapRetrySubject.eraseToAnyPublisher()
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
        addErrorLabel()
        addDescriptionLabel()
        addRetryButton()
    }

    private func addErrorLabel() {
        addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        errorLabel.text = "An error occurred:".unlocalized
        errorLabel.textAlignment = .center
        errorLabel.font = .primaryContent
    }

    private func addDescriptionLabel() {
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }

        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .primaryContent
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
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.titleLabel?.font = .title
        retryButton.layer.cornerRadius = 6
    }

    // MARK: - Actions

    @objc private func retryButtonTapped(_ sender: UIButton) {
        didTapRetrySubject.send()
    }

    // MARK: - Public methods

    func updateErrorDescription(_ description: String) {
        descriptionLabel.text = description
    }
}
