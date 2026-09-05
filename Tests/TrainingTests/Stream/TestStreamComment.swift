//
//  TestStreamComment.swift
//  Training
//
//  Created by Yuya Oka on 2026/09/05.
//

import Foundation
import Testing
@testable import Training

struct TestStreamComment {
  @Test("Encode mode is created")
  func testCreatedEncode() throws {
    let date = Date.now
    let user = UserDTO.Output(
      id: .init(uuidString: "00000000-0000-0000-0000-000000000002"),
      username: "nnsnodnb",
      dateJoined: date,
    )
    let task = TaskDTO.Output(
      id: .init(uuidString: "00000000-0000-0000-0000-000000000001")!,
      title: "タイトル",
      thumbnail: nil,
      status: .inProgress,
      user: user,
      createdAt: date,
      updatedAt: date,
    )
    let comment = CommentDTO.Output(
      id: .init(uuidString: "00000000-0000-0000-0000-000000000000")!,
      content: "コメント",
      imageIDs: ["/images/path/to/image.jpg"],
      task: task,
      user: user,
      created: date,
    )
    let streamComment = StreamComment(mode: .created(comment))

    let jsonEncoder = JSONEncoder()
    jsonEncoder.dateEncodingStrategy = .millisecondsSince1970

    let data = try jsonEncoder.encode(streamComment)
    let actual = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    guard let actual else {
      Issue.record("actual should not be nil")
      return
    }

    #expect(actual["mode"] as? String == "created")
    guard let commentActual = actual["comment"] as? [String: Any] else {
      Issue.record("comment should be dictionary")
      return
    }
    #expect(commentActual["id"] as? String == "00000000-0000-0000-0000-000000000000")
    #expect(commentActual["content"] as? String == "コメント")
    #expect(commentActual["image_ids"] as? [String] == ["/images/path/to/image.jpg"])
  }

  @Test("Encode mode is modified")
  func testModifiedEncode() throws {
    let date = Date.now
    let user = UserDTO.Output(
      id: .init(uuidString: "00000000-0000-0000-0000-000000000002"),
      username: "nnsnodnb",
      dateJoined: date,
    )
    let task = TaskDTO.Output(
      id: .init(uuidString: "00000000-0000-0000-0000-000000000001")!,
      title: "タイトル",
      thumbnail: nil,
      status: .inProgress,
      user: user,
      createdAt: date,
      updatedAt: date,
    )
    let comment = CommentDTO.Output(
      id: .init(uuidString: "00000000-0000-0000-0000-000000000000")!,
      content: "コメント",
      imageIDs: ["/images/path/to/image.jpg"],
      task: task,
      user: user,
      created: date,
    )
    let streamComment = StreamComment(mode: .modified(comment))

    let jsonEncoder = JSONEncoder()
    jsonEncoder.dateEncodingStrategy = .millisecondsSince1970

    let data = try jsonEncoder.encode(streamComment)
    let actual = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    guard let actual else {
      Issue.record("actual should not be nil")
      return
    }

    #expect(actual["mode"] as? String == "modified")
    #expect(actual["comment"] is [String: Any])
  }

  @Test("Encode mode is deleted")
  func testDeletedEncode() throws {
    let commentID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    let streamComment = StreamComment(mode: .deleted(commentID))

    let jsonEncoder = JSONEncoder()
    jsonEncoder.dateEncodingStrategy = .millisecondsSince1970

    let data = try jsonEncoder.encode(streamComment)
    let actual = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    guard let actual else {
      Issue.record("actual should not be nil")
      return
    }

    #expect(actual["mode"] as? String == "deleted")
    #expect(actual["comment_id"] as? String == "00000000-0000-0000-0000-000000000000")
  }
}
