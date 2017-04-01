//
//  ArtistViewController.swift
//  LastFMNotifier
//

import UIKit

class ArtistViewController: UIViewController {
  fileprivate let viewModel: ArtistViewModel

  init(viewModel: ArtistViewModel) {
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
    view.backgroundColor = UIColor.white
  }

  private func bindToViewModel() {
    title = viewModel.title
  }
}
