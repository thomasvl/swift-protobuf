#if swift(>=4.0)
// Not sure how to get the dependency for just the test into Package.swift.

import Foundation
import XCTest
import SwiftProtobuf
import SwiftProtobufTestSupport

extension CrossModule3_HeapStorage_Msg {
  var hashValue: Int {
    print("CrossModule3_HeapStorage_Msg.hashValue called!")
    return field1.hashValue
  }

  static func ==(lhs: CrossModule3_HeapStorage_Msg, rhs: CrossModule3_HeapStorage_Msg) -> Bool {
    return lhs.field1 == rhs.field1
  }
}


class TestHooks_CrossModule3_HeapStorage: XCTestCase {
  // Type aliases so diffing test files is easier.
  typealias MESSAGE = CrossModule3_HeapStorage_Msg
  typealias MESSAGEAsField = CrossModule3_HeapStorage_MsgAsField
  typealias MESSAGEInArray = CrossModule3_HeapStorage_MsgInArray
  typealias MESSAGEInArrayInHeapStorage = CrossModule3_HeapStorage_MsgInArrayInHeapStorage
  typealias MESSAGEInMap = CrossModule3_HeapStorage_MsgInMap
  typealias MESSAGEInMapInHeapStorage = CrossModule3_HeapStorage_MsgInMapInHeapStorage

  let msgA = MESSAGE.with {
    $0.field1 = 1
    $0.field2 = 1
  }
  let msgB = MESSAGE.with {
    $0.field1 = 1
    $0.field2 = 2
  }

  // --------------------------------------------------------------------------------------

  func testMsg() {
    XCTAssertTrue(msgA == msgB)
    XCTAssertEqual(msgA, msgB)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(msgA.hashValue, msgB.hashValue)
    XCTAssertTrue(msgA.isEqualTo(message: msgB))
  }

  func testMsgInLocalArray() {
    let localArrayA :Array<MESSAGE> = [msgA]
    let localArrayB :Array<MESSAGE> = [msgB]
    XCTAssertEqual(localArrayA, localArrayB)  // Fails: 9.0.1, 9.4.1, 10.0b4
  }

  func testMsgInLocalDictionary() {
    let localMapValueA :Dictionary<Int32,MESSAGE> = [ 1: msgA ]
    let localMapValueB :Dictionary<Int32,MESSAGE> = [ 1: msgB ]

    XCTAssertEqual(localMapValueA, localMapValueB)  // Fails: 9.0.1, 9.4.1, 10.0b4

    let localMapKeyA :Dictionary<MESSAGE,Int32> = [ msgA: 1 ]
    let localMapKeyB :Dictionary<MESSAGE,Int32> = [ msgB: 1 ]

    XCTAssertEqual(localMapKeyA, localMapKeyB)  // Fails: 9.0.1, 9.4.1, 10.0b4

    // If hash and equality are hooked right, we should be able to lookup via
    // either one.
    XCTAssertEqual(localMapKeyA[msgA], 1)
    XCTAssertEqual(localMapKeyA[msgB], 1)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(localMapKeyB[msgA], 1)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(localMapKeyB[msgB], 1)
  }

  func testMsgAsField() {
    let asFieldA = MESSAGEAsField.with {
      $0.asField = msgA
    }
    let asFieldB = MESSAGEAsField.with {
      $0.asField = msgB
    }

    XCTAssertEqual(asFieldA, asFieldB)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(asFieldA.hashValue, asFieldB.hashValue)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertTrue(asFieldA.isEqualTo(message: asFieldB))  // Fails: 9.0.1, 9.4.1, 10.0b4
  }

  func testMsgInArray() {
    let inArrayA = MESSAGEInArray.with {
      $0.inArray.append(msgA)
    }
    let inArrayB = MESSAGEInArray.with {
      $0.inArray.append(msgB)
    }

    XCTAssertEqual(inArrayA, inArrayB)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(inArrayA.hashValue, inArrayB.hashValue)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertTrue(inArrayA.isEqualTo(message: inArrayB))  // Fails: 9.0.1, 9.4.1, 10.0b4
  }

  func testMsgInArrayInHeapStorage() {
    let inArrayInHeapStorageA = MESSAGEInArrayInHeapStorage.with {
      $0.inArray.append(msgA)
    }
    let inArrayInHeapStorageB = MESSAGEInArrayInHeapStorage.with {
      $0.inArray.append(msgB)
    }

    XCTAssertEqual(inArrayInHeapStorageA, inArrayInHeapStorageB)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(inArrayInHeapStorageA.hashValue, inArrayInHeapStorageB.hashValue)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertTrue(inArrayInHeapStorageA.isEqualTo(message: inArrayInHeapStorageB))  // Fails: 9.0.1, 9.4.1, 10.0b4
  }

  func testMsgInMap() {
    let inMapA = MESSAGEInMap.with {
      $0.inMap[1] = msgA
    }
    let inMapB = MESSAGEInMap.with {
      $0.inMap[1] = msgB
    }

    XCTAssertEqual(inMapA, inMapB)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(inMapA.hashValue, inMapB.hashValue)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertTrue(inMapA.isEqualTo(message: inMapB))  // Fails: 9.0.1, 9.4.1, 10.0b4
  }

  func testMsgInMapInHeapStorage() {
    let inMapInHeapStorageA = MESSAGEInMapInHeapStorage.with {
      $0.inMap[1] = msgA
    }
    let inMapInHeapStorageB = MESSAGEInMapInHeapStorage.with {
      $0.inMap[1] = msgB
    }

    XCTAssertEqual(inMapInHeapStorageA, inMapInHeapStorageB)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(inMapInHeapStorageA.hashValue, inMapInHeapStorageB.hashValue)  // Fails: 9.0.1, 9.4.1, 10.0b4
    XCTAssertTrue(inMapInHeapStorageA.isEqualTo(message: inMapInHeapStorageB))  // Fails: 9.0.1, 9.4.1, 10.0b4
  }


}

#endif

