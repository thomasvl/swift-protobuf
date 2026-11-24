// Sources/SwiftProtobuf/BinaryEncoder.swift - Binary encoding support
//
// Copyright (c) 2014 - 2016 Apple Inc. and the project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information:
// https://github.com/apple/swift-protobuf/blob/main/LICENSE.txt
//
// -----------------------------------------------------------------------------
///
/// Core support for protobuf binary encoding.  Note that this is built
/// on the general traversal machinery.
///
// -----------------------------------------------------------------------------

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Encoder for Binary Protocol Buffer format
internal struct BinaryEncoder {
    private var pointer: UnsafeMutableRawPointer
    private var buffer: UnsafeMutableRawBufferPointer

    init(forWritingInto buffer: UnsafeMutableRawBufferPointer) {
        self.buffer = buffer
        self.pointer = buffer.baseAddress!
    }

    @inline(__always)
    private mutating func append(_ byte: UInt8) {
        pointer.storeBytes(of: byte, as: UInt8.self)
        pointer = pointer.advanced(by: 1)
    }

    private mutating func append<Bytes: SwiftProtobufContiguousBytes>(contentsOf bytes: Bytes) {
        bytes.withUnsafeBytes { dataPointer in
            if let baseAddress = dataPointer.baseAddress, dataPointer.count > 0 {
                pointer.copyMemory(from: baseAddress, byteCount: dataPointer.count)
                advance(dataPointer.count)
            }
        }
    }

    internal var used: Int {
        buffer.baseAddress!.distance(to: pointer)
    }

    internal var remainder: UnsafeMutableRawBufferPointer {
        UnsafeMutableRawBufferPointer(
            start: pointer,
            count: buffer.count - used
        )
    }

    internal mutating func advance(_ bytes: Int) {
        pointer = pointer.advanced(by: bytes)
    }

    @discardableResult
    private mutating func append(contentsOf bufferPointer: UnsafeRawBufferPointer) -> Int {
        let count = bufferPointer.count
        if let baseAddress = bufferPointer.baseAddress, count > 0 {
            pointer.copyMemory(from: baseAddress, byteCount: count)
        }
        pointer = pointer.advanced(by: count)
        return count
    }

    mutating func appendUnknown(data: Data) {
        append(contentsOf: data)
    }

    mutating func startField(fieldNumber: Int, wireFormat: WireFormat) {
        startField(tag: FieldTag(fieldNumber: fieldNumber, wireFormat: wireFormat))
    }

    mutating func startField(tag: FieldTag) {
        putVarInt(value: UInt64(tag.rawValue))
    }

    @inline(__always)
    mutating func putVarInt(value: UInt64) {
        if value < 0x80 {
            pointer.storeBytes(of: UInt8(truncatingIfNeeded: value), as: UInt8.self)
            pointer += 1
        } else {
            pointer = Self.putVarIntSlow(value, to: pointer)
        }
    }

    @inline(never)
    private static func putVarIntSlow(
        _ value: UInt64,
        to p: UnsafeMutableRawPointer
    ) -> UnsafeMutableRawPointer {
        let numBytes = Varint.encodedSize(of: value)
        switch numBytes {
        case 10:
            p.storeBytes(of: UInt8(truncatingIfNeeded: (value >> 56) | 0x80), toByteOffset: 8, as: UInt8.self)
            fallthrough
        case 9:
            p.storeBytes(of: UInt8(truncatingIfNeeded: (value >> 49) | 0x80), toByteOffset: 7, as: UInt8.self)
            fallthrough
        case 8:
            p.storeBytes(of: UInt8(truncatingIfNeeded: (value >> 42) | 0x80), toByteOffset: 6, as: UInt8.self)
            fallthrough
        case 7:
            p.storeBytes(of: UInt8(truncatingIfNeeded: (value >> 35) | 0x80), toByteOffset: 5, as: UInt8.self)
            fallthrough
        case 6:
            p.storeBytes(of: UInt8(truncatingIfNeeded: (value >> 28) | 0x80), toByteOffset: 4, as: UInt8.self)
            fallthrough
        case 5:
            p.storeBytes(of: UInt8(truncatingIfNeeded: (value >> 21) | 0x80), toByteOffset: 3, as: UInt8.self)
            fallthrough
        case 4:
            p.storeBytes(of: UInt8(truncatingIfNeeded: (value >> 14) | 0x80), toByteOffset: 2, as: UInt8.self)
            fallthrough
        case 3:
            p.storeBytes(of: UInt8(truncatingIfNeeded: (value >> 7) | 0x80), toByteOffset: 1, as: UInt8.self)
            fallthrough
        case 2:
            p.storeBytes(of: UInt8(truncatingIfNeeded: value | 0x80), toByteOffset: 0, as: UInt8.self)
            fallthrough
        case 1:
            let continuations = numBytes - 1
            p.storeBytes(
                of: UInt8(truncatingIfNeeded: value >> (7 * continuations)),
                toByteOffset: continuations,
                as: UInt8.self
            )
            return p + numBytes
        default:
            return p
        }
    }

    @inline(__always)
    mutating func putVarInt(value: Int64) {
        putVarInt(value: UInt64(bitPattern: value))
    }

    @inline(__always)
    mutating func putVarInt(value: Int) {
        putVarInt(value: Int64(value))
    }

    mutating func putZigZagVarInt(value: Int64) {
        let coded = ZigZag.encoded(value)
        putVarInt(value: coded)
    }

    mutating func putBoolValue(value: Bool) {
        append(value ? 1 : 0)
    }

    mutating func putFixedUInt64(value: UInt64) {
        var v = value.littleEndian
        let n = MemoryLayout<UInt64>.size
        pointer.copyMemory(from: &v, byteCount: n)
        pointer = pointer.advanced(by: n)
    }

    mutating func putFixedUInt32(value: UInt32) {
        var v = value.littleEndian
        let n = MemoryLayout<UInt32>.size
        pointer.copyMemory(from: &v, byteCount: n)
        pointer = pointer.advanced(by: n)
    }

    mutating func putFloatValue(value: Float) {
        let n = MemoryLayout<Float>.size
        var v = value.bitPattern.littleEndian
        pointer.copyMemory(from: &v, byteCount: n)
        pointer = pointer.advanced(by: n)
    }

    mutating func putDoubleValue(value: Double) {
        let n = MemoryLayout<Double>.size
        var v = value.bitPattern.littleEndian
        pointer.copyMemory(from: &v, byteCount: n)
        pointer = pointer.advanced(by: n)
    }

    // Write a string field, including the leading index/tag value.
    mutating func putStringValue(value: String) {
        let utf8 = value.utf8
        // If the String does not support an internal representation in a form
        // of contiguous storage, body is not called and nil is returned.
        let isAvailable = utf8.withContiguousStorageIfAvailable { (body: UnsafeBufferPointer<UInt8>) -> Int in
            putVarInt(value: body.count)
            return append(contentsOf: UnsafeRawBufferPointer(body))
        }
        if isAvailable == nil {
            let count = utf8.count
            putVarInt(value: count)
            for b in utf8 {
                pointer.storeBytes(of: b, as: UInt8.self)
                pointer = pointer.advanced(by: 1)
            }
        }
    }

    mutating func putBytesValue<Bytes: SwiftProtobufContiguousBytes>(value: Bytes) {
        putVarInt(value: value.count)
        append(contentsOf: value)
    }
}
