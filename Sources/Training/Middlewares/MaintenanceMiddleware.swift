//
//  MaintenanceMiddleware.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/18.
//

import Foundation
import Vapor

struct MaintenanceMiddleware: AsyncMiddleware {
  // MARK: - Mode
  enum Mode: String {
    case on = "1"
    case off = "0"
  }

  // MARK: - Properties
  static let maintenanceTextFileName = ".maintenance.txt"

  func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
    let fileManager = FileManager.default
    let maintenanceTextFilePath = "\(request.application.directory.workingDirectory)\(Self.maintenanceTextFileName)"
    // .maintenance.txtがなければリクエストを流す
    guard fileManager.fileExists(atPath: maintenanceTextFilePath) else {
      return try await next.respond(to: request)
    }
    let mode: Mode
    do {
      let url = URL(fileURLWithPath: request.application.directory.workingDirectory)
        .appending(path: Self.maintenanceTextFileName)
      let data = try Data(contentsOf: url)
      guard let raw = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
            let unwrappedMode = Mode(rawValue: raw) else {
        throw Abort(.internalServerError)
      }
      mode = unwrappedMode
    } catch {
      throw Abort(.internalServerError)
    }
    switch mode {
    case .on:
      let response = Response(status: .serviceUnavailable)
      let date = Date.now.addingTimeInterval(60 * 60 * 11)
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy年MM月dd日 HH時00分"
      let body = Maintenance(
        errorDetail: .init(
          title: "現在サービスはメンテナンス中です。",
          body: "終了は\(dateFormatter.string(from: date))を予定しています。",
        ),
      )
      try response.content.encode(body)
      return response
    case .off:
      // メンテナンスモードではないのでリクエストを流す
      return try await next.respond(to: request)
    }
  }
}
