//
//  PatchTaskStatusValidator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/15.
//

import Vapor

struct PatchTaskStatusValidator: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("status", as: Task.Status.self, is: .valid, required: true)
  }
}
