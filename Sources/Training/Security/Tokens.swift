//
//  Tokens.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Foundation
import JWT
import Vapor

struct Tokens: Content {
  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case refreshToken = "refresh"
    case accessToken = "access"
  }

  let refreshToken: String
  let accessToken: String
}
