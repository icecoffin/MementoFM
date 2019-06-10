//
//  ArtistInfoSectionDataSource.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class ArtistInfoSectionDataSource: ArtistSectionDataSource {
  private let viewModel: ArtistInfoSectionViewModel
  var didUpdateData: (() -> Void)?

  init(viewModel: ArtistInfoSectionViewModel) {
    self.viewModel = viewModel
  }

  var numberOfRows: Int {
    return 1
  }

  func registerReusableViews(in tableView: UITableView) {
    tableView.register(ArtistInfoCell.self, forCellReuseIdentifier: ArtistInfoCell.reuseIdentifier)
  }

  func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoCell.reuseIdentifier,
                                                   for: indexPath) as? ArtistInfoCell else {
      fatalError("ArtistInfoCell is not registered in the collection view")
    }

    let cellViewModel = viewModel.itemViewModel(at: indexPath.item)
    cell.configure(with: cellViewModel)
    return cell
  }
}
