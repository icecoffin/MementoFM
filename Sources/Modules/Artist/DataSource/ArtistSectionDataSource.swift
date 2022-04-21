//
//  ArtistSectionDataSource.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import Combine

protocol ArtistSectionDataSource: AnyObject {
    var didUpdateData: AnyPublisher<Void, Error> { get }

    var numberOfRows: Int { get }

    func registerReusableViews(in tableView: UITableView)
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell

    func shouldHighlightRow(at indexPath: IndexPath, in tableView: UITableView) -> Bool
    func selectRow(at indexPath: IndexPath, in tableView: UITableView)

    func viewForHeader(inSection: Int, in tableView: UITableView) -> UITableViewHeaderFooterView?
    func heightForHeader(inSection section: Int, in tableView: UITableView) -> CGFloat

    func viewForFooter(inSection: Int, in tableView: UITableView) -> UITableViewHeaderFooterView?
    func heightForFooter(inSection section: Int, in tableView: UITableView) -> CGFloat
}

extension ArtistSectionDataSource {
    func shouldHighlightRow(at indexPath: IndexPath, in tableView: UITableView) -> Bool {
        return false
    }

    func selectRow(at indexPath: IndexPath, in tableView: UITableView) {

    }

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
