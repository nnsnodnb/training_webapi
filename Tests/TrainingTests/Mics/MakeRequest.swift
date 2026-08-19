//
//  MakeRequest.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/16.
//

import Foundation
import VaporTesting

func makeRequest(_ test: (Request) async throws -> ()) async throws {
  let app = try await Application.make(.testing)
  app.http.server.configuration.hostname = "127.0.0.1"
  app.http.server.configuration.port = 8080
  let headers = HTTPHeaders()
  let request = Request(
    application: app,
    method: .GET,
    url: URI(string: "/"),
    headers: headers,
    on: app.eventLoopGroup.any(),
  )
  try await test(request)
  try await app.asyncShutdown()
}
