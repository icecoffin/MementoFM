//
//  ArtistDataSource.swift
//  MementoFM
//
//  Created by Daniel on 12/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import Combine

final class ArtistDataSource: NSObject {
    // MARK: - Private properties

    private let viewModel: ArtistViewModelProtocol

    private var didUpdateDataSubject = PassthroughSubject<Void, Error>()
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Public properties

    let sectionDataSources: [ArtistSectionDataSource]

    var didUpdateData: AnyPublisher<Void, Error> {
        return didUpdateDataSubject.eraseToAnyPublisher()
    }

    // MARK: - Init

    init(viewModel: ArtistViewModelProtocol) {
        self.viewModel = viewModel
        sectionDataSources = viewModel.sectionDataSources
        super.init()

        bindToViewModel()
    }

    // MARK: - Private properties

    private func bindToViewModel() {
        viewModel.didUpdateData
            .sink { [unowned self] completion in
                self.didUpdateDataSubject.send(completion: completion)
            } receiveValue: { [unowned self] in
                self.didUpdateDataSubject.send()
            }
            .store(in: &cancelBag)
    }

    // MARK: - Public methods

    func registerReusableViews(in tableView: UITableView) {
        sectionDataSources.forEach { $0.registerReusableViews(in: tableView) }
    }
}

// MARK: - UITableViewDataSource

extension ArtistDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDataSources.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionDataSources[section].numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sectionDataSources[indexPath.section].cellForRow(at: indexPath, in: tableView)
    }
}

// MARK: - UITableViewDelegate

extension ArtistDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return sectionDataSources[indexPath.section].shouldHighlightRow(at: indexPath, in: tableView)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        sectionDataSources[indexPath.section].selectRow(at: indexPath, in: tableView)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionDataSources[section].viewForHeader(inSection: section, in: tableView)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionDataSources[section].heightForHeader(inSection: section, in: tableView)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sectionDataSources[section].viewForFooter(inSection: section, in: tableView)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionDataSources[section].heightForFooter(inSection: section, in: tableView)
    }
}
