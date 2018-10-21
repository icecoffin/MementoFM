//
//  ArtistListViewModel.swift
//  MementoFM
//
//  Created by Daniel on 19/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol ArtistListViewModelDelegate: class {
  func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist)
}

protocol ArtistListViewModel: class {
  var delegate: ArtistListViewModelDelegate? { get set }

  var onDidStartLoading: (() -> Void)? { get set }
  var onDidFinishLoading: (() -> Void)? { get set }
  var onDidUpdateData: ((_ isEmpty: Bool) -> Void)? { get set }
  var onDidChangeStatus: ((String) -> Void)? { get set }
  var onDidReceiveError: ((Error) -> Void)? { get set }

  var itemCount: Int { get }
  var title: String { get }
  var searchBarPlaceholder: String { get }

  func requestDataIfNeeded(currentTimestamp: TimeInterval, minTimeInterval: TimeInterval)
  func artistViewModel(at indexPath: IndexPath) -> LibraryArtistCellViewModel
  func selectArtist(at indexPath: IndexPath)
  func performSearch(withText text: String)
}

extension ArtistListViewModel {
  func requestDataIfNeeded(currentTimestamp: TimeInterval = Date().timeIntervalSince1970,
                           minTimeInterval: TimeInterval = 30) {
    requestDataIfNeeded(currentTimestamp: currentTimestamp, minTimeInterval: minTimeInterval)
  }

  var searchBarPlaceholder: String {
    return "Search".unlocalized
  }
}
