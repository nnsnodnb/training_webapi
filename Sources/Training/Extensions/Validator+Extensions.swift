//
//  Validator+Extensions.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/18.
//

import Foundation
import Vapor

extension Validator where T == [File] {
  static func mimeTypeIsImage() -> Validator<T> {
    .custom("mime_type must be image") { file in
      file.lazy.contains(where: { $0.contentType?.type == "image" })
    }
  }
}
