//
//  EnterUsernameViewController.swift
//  MementoFM
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

final class EnterUsernameViewController: UIViewController {
  private let stackView = UIStackView()
  private let currentUsernameLabel = UILabel()
  private let usernameTextField = UITextField()
  private let submitButton = UIButton(type: .system)

  private let viewModel: EnterUsernameViewModel

  init(viewModel: EnterUsernameViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    bindToViewModel()
  }

  private func configureView() {
    view.backgroundColor = UIColor.white
    addStackView()
    addCurrentUsernameLabel()
    addUsernameTextField()
    addSubmitButton()
  }

  private func addStackView() {
    view.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.centerY.equalToSuperview().offset(-100)
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

    currentUsernameLabel.font = .raleway(withSize: 16)
  }

  private func addUsernameTextField() {
    stackView.addArrangedSubview(usernameTextField)
    usernameTextField.snp.makeConstraints { make in
      make.height.equalTo(34)
    }

    usernameTextField.borderStyle = .roundedRect
    usernameTextField.backgroundColor = .white

    usernameTextField.autocapitalizationType = .none
    usernameTextField.autocorrectionType = .no
    usernameTextField.returnKeyType = .done
    usernameTextField.delegate = self

    usernameTextField.textAlignment = .center
    usernameTextField.font = .raleway(withSize: 16)

    usernameTextField.addTarget(self, action: #selector(usernameTextFieldEditingChanged(_:)), for: .editingChanged)
  }

  private func addSubmitButton() {
    stackView.addArrangedSubview(submitButton)
    submitButton.snp.makeConstraints { make in
      make.width.equalTo(120)
      make.height.equalTo(40)
    }

    submitButton.setTitleColor(UIColor.white, for: .normal)
    submitButton.titleLabel?.font = .ralewayBold(withSize: 18)
    submitButton.layer.cornerRadius = 6
    disableSubmitButton()

    submitButton.addTarget(self, action: #selector(submitButtonTapped(_:)), for: .touchUpInside)
  }

  @objc private func submitButtonTapped(_ sender: UIButton) {
    viewModel.submitUsername()
  }

  private func bindToViewModel() {
    viewModel.onDidStartRequest = {
      HUD.show()
    }

    viewModel.onDidFinishRequest = {
      HUD.dismiss()
    }

    viewModel.onDidReceiveError = { [weak self] error in
      self?.showAlert(for: error)
    }

    usernameTextField.placeholder = viewModel.usernameTextFieldPlaceholder
    submitButton.setTitle(viewModel.submitButtonTitle, for: .normal)
    currentUsernameLabel.text = viewModel.currentUsernameText
  }

  // MARK: Actions
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
    submitButton.backgroundColor = .bayLeaf
  }
}

// MARK: UITextField delegate
extension EnterUsernameViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if viewModel.canSubmitUsername {
      viewModel.submitUsername()
    }
    return true
  }
}
