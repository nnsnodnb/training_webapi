//
//  MaintenanceCommand.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/18.
//

import Foundation
import Vapor

struct MaintenanceCommand: AsyncCommand {
  // MARK: - Signature
  struct Signature: CommandSignature {
    @Argument(name: "mode", help: "Maintenance mode", completion: .values(["on", "off"]))
    var mode: String
  }

  // MARK: - Error
  private enum Error: Swift.Error, CustomStringConvertible {
    case invalidArgument

    // MARK: - CustomStringConvertible
    var description: String {
      switch self {
      case .invalidArgument:
        "Invalid argument. Use 'on' or 'off'"
      }
    }
  }

  // MARK: - Properties
  let help: String = "Change maintenance mode"

  func run(using context: CommandContext, signature: Signature) async throws {
    do {
      let mode: MaintenanceMiddleware.Mode = if signature.mode == "on" {
        .on
      } else if signature.mode == "off" {
        .off
      } else {
        throw Error.invalidArgument
      }
      // swiftlint:disable:next line_length
      let maintenanceTextFilePath = "\(context.application.directory.workingDirectory)\(MaintenanceMiddleware.maintenanceTextFileName)"
      _ = FileManager.default.createFile(atPath: maintenanceTextFilePath, contents: mode.rawValue.data(using: .utf8))
      context.console.output("Maintenance mode is set to \(signature.mode)", style: .success, newLine: true)
    } catch let error as Error {
      context.console.output(error.description, style: .error, newLine: true)
    }
  }
}
