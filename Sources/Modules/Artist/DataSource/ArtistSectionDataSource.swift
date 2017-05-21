//
//  ArtistSectionDataSource.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol ArtistSectionDataSource: class {
  var onDidUpdateData: (() -> Void)? { get set }

  var numberOfRows: Int { get }

  func registerReusableViews(in tableView: UITableView)
  func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell

  func viewForHeader(inSection: Int, in tableView: UITableView) -> UITableViewHeaderFooterView?
  func heightForHeader(inSection section: Int, in tableView: UITableView) -> CGFloat

  func viewForFooter(inSection: Int, in tableView: UITableView) -> UITableViewHeaderFooterView?
  func heightForFooter(inSection section: Int, in tableView: UITableView) -> CGFloat
}

extension ArtistSectionDataSource {
  func viewForHeader(inSection: Int, in tableView: UITableView) -> UITableViewHeaderFooterView? {
    return nil
  }

  func heightForHeader(inSection section: Int, in tableView: UITableView) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }

  func viewForFooter(inSection: Int, in tableView: UITableView) -> UITableViewHeaderFooterView? {
    return nil
  }

  func heightForFooter(inSection section: Int, in tableView: UITableView) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }
}
