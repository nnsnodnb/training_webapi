//
//  ImageDTO.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/16.
//

import Foundation
import Vapor

struct ImageDTO: Content {
  let items: [File]
}

// MARK: - Output
extension ImageDTO {
  struct Output: Content {
    let items: [String]
  }
}
