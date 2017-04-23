//
//  ArtistViewController.swift
//  LastFMNotifier
//

import UIKit

class ArtistViewController: UIViewController {
  fileprivate let viewModel: ArtistViewModel

  private let imageView = UIImageView()
  let tagsLabel = UILabel()

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

    view.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(16)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(120)
    }
    imageView.layer.cornerRadius = 60
    imageView.layer.masksToBounds = true

    view.addSubview(tagsLabel)
    tagsLabel.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(16)
    }

    tagsLabel.numberOfLines = 0
  }

  private func bindToViewModel() {
    title = viewModel.title
    tagsLabel.text = viewModel.tags
    imageView.kf.setImage(with: viewModel.imageURL)
  }
}
