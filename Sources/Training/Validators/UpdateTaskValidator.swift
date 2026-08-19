//
//  UpdateTaskValidator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/15.
//

import Vapor

struct UpdateTaskValidator: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("title", as: String.self, is: !.empty, required: true)
    validations.add("thumbnail", as: String?.self, is: .nil || !.empty, required: false)
    validations.add("status", as: Task.Status.self, is: .valid, required: true)
  }
}
