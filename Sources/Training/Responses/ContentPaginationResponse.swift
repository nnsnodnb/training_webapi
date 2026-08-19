//
//  ContentPaginationResponse.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/15.
//

import Foundation
import Vapor

struct ContentPaginationResponse<T: Content>: Content {
  // MARK: - Properties
  let items: [T]
  let next: String?
  let previous: String?
}
