import Fluent
import Vapor

func routes(_ app: Application) throws {
  try app.register(collection: TaskController())
  try app.register(collection: UserController())
  try app.register(collection: ImageController())
  try app.register(collection: CommentController())
}
