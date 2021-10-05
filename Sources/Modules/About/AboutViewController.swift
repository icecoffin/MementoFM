//
//  AboutViewController.swift
//  MementoFM
//
//  Created by Daniel on 04/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class AboutViewController: UIViewController {
    // MARK: - Private properties

    private let scrollView = UIScrollView()
    private let textView = UITextView()

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    // MARK: - Private methods

    private func configureView() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }

        textView.font = .primaryContent
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = [.link]
        textView.text = "Artist information and tags are provided by Last.fm (https://last.fm/api/).".unlocalized
    }
}
