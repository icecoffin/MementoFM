//
//  ArtistViewController.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController {
  fileprivate let viewModel: ArtistViewModel

  private let scrollView = UIScrollView()
  private let imageView = UIImageView()
  private let tagsLabel = UILabel()
  private let similarArtistsLabel = UILabel()

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
    view.backgroundColor = .white

    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    scrollView.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(120)
    }
    imageView.layer.cornerRadius = 60
    imageView.layer.masksToBounds = true

    scrollView.addSubview(tagsLabel)
    tagsLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(imageView.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(16)
    }
    tagsLabel.numberOfLines = 0

    scrollView.addSubview(similarArtistsLabel)
    similarArtistsLabel.snp.makeConstraints { make in
      make.top.equalTo(tagsLabel.snp.bottom).offset(16)
      make.leading.trailing.bottom.equalToSuperview().inset(16)
    }
    similarArtistsLabel.numberOfLines = 0
  }

  private func bindToViewModel() {
    imageView.kf.setImage(with: viewModel.imageURL)
    tagsLabel.text = viewModel.tags
    similarArtistsLabel.text = viewModel.similarArtists
  }
}
