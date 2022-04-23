//
//  Completion+AsResult.swift
//  MementoFM
//
//  Created by Dani on 23.04.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import Foundation
import Combine

extension Subscribers.Completion {
    var asResult: Result<Void, Failure> {
        switch self {
        case .finished:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
