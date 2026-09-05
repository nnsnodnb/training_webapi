//
//  WithApp.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/13.
//

import Fluent
import Foundation
@testable import Training
import VaporTesting

func withMigrationApp(_ test: (Application) async throws -> Void) async throws {
  let app = try await Application.make(.testing)
  do {
    try await configure(app, inMemory: true)
    try await app.autoMigrate()
    try await test(app)
    try await app.autoRevert()
  } catch {
    try? await app.autoRevert()
    try await app.asyncShutdown()
    throw error
  }
  try await app.asyncShutdown()
}
