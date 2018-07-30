// Sources/SwiftProtobuf/Message.swift - Message support
//
// Copyright (c) 2018 Apple Inc. and the project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information:
// https://github.com/apple/swift-protobuf/blob/master/LICENSE.txt
//

internal protocol _AnyMessageBox {
  var _message: Message { get }
  func _unbox<M: Message>() -> M?

  func _isEqual(to box: _AnyMessageBox) -> Bool?
  var _hashValue: Int { get }
}

internal struct _ConcreteAnyMessageBox<M: Message>: _AnyMessageBox {
  internal var _baseMessage: M

  internal init(_ base: M) {
    self._baseMessage = base
  }

  internal var _message: Message {
    return _baseMessage
  }

  internal func _unbox<T: Message>() -> T? {
    return (self as _AnyMessageBox as? _ConcreteAnyMessageBox<T>)?._baseMessage
  }

  internal func _isEqual(to rhs: _AnyMessageBox) -> Bool? {
    if let rhs: M = rhs._unbox() {
      // ### Fix this when equatable moves on to Message
      // ### return _baseMessage == rhs
      return _baseMessage.isEqualTo(message: rhs)
    }
    return nil
  }

  internal var _hashValue: Int {
    return _baseMessage.hashValue
  }

}

/// Type erasure wrapper for Message so it can be used for cases where the
/// specific type of the Message isn't known.
///
/// It doesn not conform to Message the serialized forms of Messages don't
/// include the message typo, so there would be no way to read them back
/// in; to something higher level needs to capture the types to then write
/// out the data with any expectation of being able to read them back in.
public struct AnyMessage {
  private var _box: _AnyMessageBox

  public init<M: Message>(_ message: M) {
    _box = _ConcreteAnyMessageBox(message)
  }

  public var message: Message {
    return _box._message
  }
}

extension AnyMessage: CustomStringConvertible {
  public var description: String {
    return String(describing: message)
  }
}

extension AnyMessage: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "SwiftProtobuf.AnyMessage(" + String(reflecting: message) + ")"
  }
}

extension AnyMessage: CustomReflectable {
  public var customMirror: Mirror {
    return Mirror(
      self,
      children: ["message": message])
  }
}

extension AnyMessage: Equatable {
  public static func == (lhs: AnyMessage, rhs: AnyMessage) -> Bool {
    return lhs._box._isEqual(to: rhs._box) ?? false
  }
}

extension AnyMessage: Hashable {
  public var hashValue: Int {
    return _box._hashValue;
  }
}
