import Foundation
import XCTest
import SwiftProtobuf


extension SameModule2_Msg {
  var hashValue: Int {
    print("SameModule2_Msg.hashValue called!")
    return field1.hashValue
  }

  static func ==(lhs: SameModule2_Msg, rhs: SameModule2_Msg) -> Bool {
    return lhs.hasField1 == rhs.hasField2 && lhs.field1 == rhs.field1
  }
}


class TestHooks_SameModule2: XCTestCase {
  // Type aliases so diffing test files is easier.
  typealias MESSAGE = SameModule2_Msg
  typealias MESSAGEAsField = SameModule2_MsgAsField
  typealias MESSAGEInArray = SameModule2_MsgInArray
  typealias MESSAGEInArrayInHeapStorage = SameModule2_MsgInArrayInHeapStorage
  typealias MESSAGEInMap = SameModule2_MsgInMap
  typealias MESSAGEInMapInHeapStorage = SameModule2_MsgInMapInHeapStorage

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
    XCTAssertEqual(msgA, msgB)  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(msgA.hashValue, msgB.hashValue)
    XCTAssertTrue(msgA.isEqualTo(message: msgB))
  }

  func testMsgInLocalArray() {
    let localArrayA :Array<MESSAGE> = [msgA]
    let localArrayB :Array<MESSAGE> = [msgB]
    XCTAssertEqual(localArrayA, localArrayB)  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
  }

  func testMsgInLocalDictionary() {
    let localMapValueA :Dictionary<Int32,MESSAGE> = [ 1: msgA ]
    let localMapValueB :Dictionary<Int32,MESSAGE> = [ 1: msgB ]

    XCTAssertEqual(localMapValueA, localMapValueB)  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4

    let localMapKeyA :Dictionary<MESSAGE,Int32> = [ msgA: 1 ]
    let localMapKeyB :Dictionary<MESSAGE,Int32> = [ msgB: 1 ]

    XCTAssertEqual(localMapKeyA, localMapKeyB)  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4

    // If hash and equality are hooked right, we should be able to lookup via
    // either one.
    XCTAssertEqual(localMapKeyA[msgA], 1)
    XCTAssertEqual(localMapKeyA[msgB], 1)  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(localMapKeyB[msgA], 1)  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(localMapKeyB[msgB], 1)
  }

  func testMsgAsField() {
    let asFieldA = MESSAGEAsField.with {
      $0.asField = msgA
    }
    let asFieldB = MESSAGEAsField.with {
      $0.asField = msgB
    }

    XCTAssertEqual(asFieldA, asFieldB)  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(asFieldA.hashValue, asFieldB.hashValue)
    XCTAssertTrue(asFieldA.isEqualTo(message: asFieldB))  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
  }

  func testMsgInArray() {
    let inArrayA = MESSAGEInArray.with {
      $0.inArray.append(msgA)
    }
    let inArrayB = MESSAGEInArray.with {
      $0.inArray.append(msgB)
    }

    XCTAssertEqual(inArrayA, inArrayB)  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(inArrayA.hashValue, inArrayB.hashValue)
    XCTAssertTrue(inArrayA.isEqualTo(message: inArrayB))  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
  }

  func testMsgInArrayInHeapStorage() {
    let inArrayInHeapStorageA = MESSAGEInArrayInHeapStorage.with {
      $0.inArray.append(msgA)
    }
    let inArrayInHeapStorageB = MESSAGEInArrayInHeapStorage.with {
      $0.inArray.append(msgB)
    }

    XCTAssertEqual(inArrayInHeapStorageA, inArrayInHeapStorageB)  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(inArrayInHeapStorageA.hashValue, inArrayInHeapStorageB.hashValue)
    XCTAssertTrue(inArrayInHeapStorageA.isEqualTo(message: inArrayInHeapStorageB))  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
  }

  func testMsgInMap() {
    let inMapA = MESSAGEInMap.with {
      $0.inMap[1] = msgA
    }
    let inMapB = MESSAGEInMap.with {
      $0.inMap[1] = msgB
    }

    XCTAssertEqual(inMapA, inMapB)  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(inMapA.hashValue, inMapB.hashValue)
    XCTAssertTrue(inMapA.isEqualTo(message: inMapB))  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
  }

  func testMsgInMapInHeapStorage() {
    let inMapInHeapStorageA = MESSAGEInMapInHeapStorage.with {
      $0.inMap[1] = msgA
    }
    let inMapInHeapStorageB = MESSAGEInMapInHeapStorage.with {
      $0.inMap[1] = msgB
    }

    XCTAssertEqual(inMapInHeapStorageA, inMapInHeapStorageB)  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
    XCTAssertEqual(inMapInHeapStorageA.hashValue, inMapInHeapStorageB.hashValue)
    XCTAssertTrue(inMapInHeapStorageA.isEqualTo(message: inMapInHeapStorageB))  // Fails: 8.3.3, 9.0.1, 9.4.1, 10.0b4
  }


}

