//
//  SignInValidator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Foundation
import Vapor

struct SignInValidator: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("username", as: String.self, is: !.empty, required: true)
    validations.add("password", as: String.self, is: .count(8...))
  }
}
