//
//  ErrorResponse.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Foundation
import Vapor

struct ErrorResponse: Content {
  let error: String
}
