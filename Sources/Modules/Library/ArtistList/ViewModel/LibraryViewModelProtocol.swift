//
//  LibraryViewModelProtocol.swift
//  LastFMNotifier
//
//  Created by Daniel on 19/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol LibraryViewModelDelegate: class {
  func libraryViewModel(_ viewModel: LibraryViewModelProtocol, didSelectArtist artist: Artist)
}

protocol LibraryViewModelProtocol: class {
  weak var delegate: LibraryViewModelDelegate? { get set }

  var onDidStartLoading: (() -> Void)? { get set }
  var onDidFinishLoading: (() -> Void)? { get set }
  var onDidUpdateData: ((_ isEmpty: Bool) -> Void)? { get set }
  var onDidChangeStatus: ((String) -> Void)? { get set }
  var onDidReceiveError: ((Error) -> Void)? { get set }

  var itemCount: Int { get }
  var searchBarPlaceholder: String { get }

  func requestDataIfNeeded(currentTimestamp: TimeInterval)
  func artistViewModel(at indexPath: IndexPath) -> LibraryArtistCellViewModel
  func selectArtist(at indexPath: IndexPath)
  func performSearch(withText text: String)
}

extension LibraryViewModelProtocol {
  func requestDataIfNeeded(currentTimestamp: TimeInterval = Date().timeIntervalSince1970) {
    requestDataIfNeeded(currentTimestamp: currentTimestamp)
  }

  var searchBarPlaceholder: String {
    return "Search".unlocalized
  }
}
