//
//  migrations.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/17.
//

import Fluent
import Vapor

func migrations(_ app: Application) {
  app.migrations.add(InitialMigrations())
  app.migrations.add(AddUserFieldInCommentMigrations())
}
