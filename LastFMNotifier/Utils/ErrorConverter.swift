//
//  ErrorConverter.swift
//  LastFMNotifier
//
//  Created by Daniel on 30/03/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

enum ErrorConverter {
  static func displayMessage(for error: Error) -> String {
    if let mapperError = error as? MapperError {
      return displayMessage(for: mapperError)
    } else {
      return error.localizedDescription
    }
  }

  private static func displayMessage(for mapperError: MapperError) -> String {
    switch mapperError {
    case .convertibleError(let value, let type):
      return "Mapping error: can't convert value \(value) to type \(type)"
    case .customError(_, let message):
      return "Mapping error: \(message)"
    case .invalidRawValueError(let field, let value, let type):
      return "Mapping error: invalid raw value \(value) of type \(type) in field \(field)"
    case .missingFieldError(let field):
      return "Mapping error: missing field \(field)"
    case .typeMismatchError(let field, let value, let type):
      return "Mapping error: type mismatch: value \(value) doesn't match type \(type) of field \(field)"
    }
  }
}
