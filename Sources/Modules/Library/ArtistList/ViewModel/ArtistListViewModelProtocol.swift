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

  var didStartLoading: (() -> Void)? { get set }
  var didFinishLoading: (() -> Void)? { get set }
  var didUpdateData: ((_ isEmpty: Bool) -> Void)? { get set }
  var didChangeStatus: ((String) -> Void)? { get set }
  var didReceiveError: ((Error) -> Void)? { get set }

  var itemCount: Int { get }
  var title: String { get }
  var searchBarPlaceholder: String { get }

  func requestDataIfNeeded(currentTimestamp: TimeInterval, minTimeInterval: TimeInterval)
  func artistViewModel(at indexPath: IndexPath) -> LibraryArtistCellViewModel
  func selectArtist(at indexPath: IndexPath)
  func performSearch(withText text: String)
}

extension ArtistListViewModel {
  func requestDataIfNeeded() {
    requestDataIfNeeded(currentTimestamp: Date().timeIntervalSince1970, minTimeInterval: 30)
  }

  var searchBarPlaceholder: String {
    return "Search".unlocalized
  }
}
