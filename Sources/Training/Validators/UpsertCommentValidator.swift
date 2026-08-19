//
//  UpsertCommentValidator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/17.
//

import Foundation
import Vapor

struct UpsertCommentValidator: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("content", as: String.self, is: !.empty && .count(1...500), required: true)
    validations.add("image_ids", as: [String].self, is: .count(0...4), required: true)
  }
}
