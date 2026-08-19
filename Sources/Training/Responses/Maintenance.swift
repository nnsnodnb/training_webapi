//
//  Maintenance.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/18.
//

import Foundation
import Vapor

struct Maintenance: Content {
  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case errorDetail = "error_detail"
  }

  // MARK: - Properties
  let errorDetail: ErrorDetail
}

extension Maintenance {
  struct ErrorDetail: Content {
    // MARK: - Properties
    let title: String
    let body: String
  }
}
