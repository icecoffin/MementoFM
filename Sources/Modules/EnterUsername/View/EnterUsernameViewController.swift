//
//  EnterUsernameViewController.swift
//  MementoFM
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import Combine

final class EnterUsernameViewController: UIViewController {
    // MARK: - Private properties

    private let stackView = UIStackView()
    private let currentUsernameLabel = UILabel()
    private let usernameTextField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let viewModel: EnterUsernameViewModel
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Init

    init(viewModel: EnterUsernameViewModel) {
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        bindToViewModel()
    }

    // MARK: - Private methods

    private func configureView() {
        view.backgroundColor = .systemBackground
        addStackView()
        addCurrentUsernameLabel()
        addUsernameTextField()
        addSubmitButton()
        addActivityIndicator()
    }

    private func addStackView() {
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(250)
        }

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 24
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 44)
    }

    private func addCurrentUsernameLabel() {
        stackView.addArrangedSubview(currentUsernameLabel)

        currentUsernameLabel.font = .primaryContent
    }

    private func addUsernameTextField() {
        stackView.addArrangedSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        usernameTextField.borderStyle = .roundedRect
        usernameTextField.backgroundColor = .systemBackground

        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.returnKeyType = .done
        usernameTextField.delegate = self

        usernameTextField.textAlignment = .center
        usernameTextField.font = .primaryContent

        usernameTextField.addTarget(self, action: #selector(usernameTextFieldEditingChanged(_:)), for: .editingChanged)
    }

    private func addSubmitButton() {
        stackView.addArrangedSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(40)
        }

        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = .title
        submitButton.layer.cornerRadius = 6
        disableSubmitButton()

        submitButton.addTarget(self, action: #selector(submitButtonTapped(_:)), for: .touchUpInside)
    }

    private func addActivityIndicator() {
        stackView.addArrangedSubview(activityIndicator)
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
    }

    @objc private func submitButtonTapped(_ sender: UIButton) {
        viewModel.submitUsername()
    }

    private func bindToViewModel() {
        viewModel.isLoading
            .sink { [weak self] isLoading in
                guard let self = self else { return }

                if isLoading {
                    self.disableSubmitButton()
                    self.activityIndicator.startAnimating()
                } else {
                    self.enableSubmitButton()
                    self.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancelBag)

        viewModel.error
            .sink(receiveValue: { [weak self] error in
                self?.enableSubmitButton()
                self?.activityIndicator.stopAnimating()
                self?.showAlert(for: error)
            })
            .store(in: &cancelBag)

        usernameTextField.placeholder = viewModel.usernameTextFieldPlaceholder
        submitButton.setTitle(viewModel.submitButtonTitle, for: .normal)
        currentUsernameLabel.text = viewModel.currentUsernameText
    }

    // MARK: - Actions

    @objc private func usernameTextFieldEditingChanged(_ textField: UITextField) {
        viewModel.updateUsername(textField.text)
        if viewModel.canSubmitUsername {
            enableSubmitButton()
        } else {
            disableSubmitButton()
        }
    }

    private func disableSubmitButton() {
        submitButton.isEnabled = false
        submitButton.backgroundColor = .gray
    }

    private func enableSubmitButton() {
        submitButton.isEnabled = true
        submitButton.backgroundColor = .appPrimary
    }
}

// MARK: - UITextFieldDelegate

extension EnterUsernameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if viewModel.canSubmitUsername {
            viewModel.submitUsername()
        }
        return true
    }
}
