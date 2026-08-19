//
//  UploadImageValidator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/16.
//

import Vapor

struct UploadImageValidator: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("items", as: [File].self, is: .count(1...4) && .mimeTypeIsImage(), required: true)
  }
}
