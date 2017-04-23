//
//  EnterUsernameViewController.swift
//  LastFMNotifier
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

class EnterUsernameViewController: UIViewController {
  private let stackView = UIStackView()
  private let currentUsernameLabel = UILabel()
  private let usernameTextField = UITextField()
  private let submitButton = UIButton(type: .system)

  fileprivate let viewModel: EnterUsernameViewModel

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

    currentUsernameLabel.font = Fonts.raleway(withSize: 16)
    currentUsernameLabel.text = viewModel.currentUsernameText
  }

  private func addUsernameTextField() {
    stackView.addArrangedSubview(usernameTextField)
    usernameTextField.snp.makeConstraints { make in
      make.height.equalTo(34)
    }

    usernameTextField.borderStyle = .roundedRect
    usernameTextField.backgroundColor = .white

    usernameTextField.autocorrectionType = .no
    usernameTextField.returnKeyType = .done
    usernameTextField.delegate = self

    usernameTextField.placeholder = NSLocalizedString("Enter your last.fm username", comment: "")
    usernameTextField.textAlignment = .center
    usernameTextField.font = Fonts.raleway(withSize: 16)
  }

  private func addSubmitButton() {
    stackView.addArrangedSubview(submitButton)
    submitButton.snp.makeConstraints { make in
      make.width.equalTo(120)
      make.height.equalTo(40)
    }

    submitButton.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
    submitButton.setTitleColor(UIColor.white, for: .normal)
    submitButton.titleLabel?.font = Fonts.ralewayBold(withSize: 18)
    submitButton.backgroundColor = Colors.gold
    submitButton.layer.cornerRadius = 6

    submitButton.addTarget(self, action: #selector(submitButtonTapped(_:)), for: .touchUpInside)
  }

  func submitButtonTapped(_ sender: UIButton) {
    submitUsername()
  }

  fileprivate func submitUsername() {
    let username = usernameTextField.text ?? ""
    viewModel.submitUsername(username)
  }
}

// MARK: Modal presentation configuration
extension EnterUsernameViewController {
  func configureForModalPresentation() {
    let closeButton = UIButton(type: .system)
    view.addSubview(closeButton)
    closeButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.top.equalToSuperview().offset(36)
    }

    closeButton.setImage(#imageLiteral(resourceName: "icon_close"), for: .normal)
    closeButton.tintColor = Colors.gold

    closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
  }

  func closeButtonTapped(_ sender: UIButton) {
    viewModel.close()
  }
}

// MARK: UITextField delegate
extension EnterUsernameViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    submitUsername()
    return true
  }
}
