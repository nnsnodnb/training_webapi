//
//  RefreshValidator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Vapor

struct RefreshValidator: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("refresh", as: String.self, is: !.empty, required: true)
  }
}
