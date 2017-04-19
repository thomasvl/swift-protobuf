// Package.swift - description
//
// Copyright (c) 2014 - 2017 Apple Inc. and the project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information:
// https://github.com/apple/swift-protobuf/blob/master/LICENSE.txt
//

import PackageDescription

let package = Package(
  name: "IntegrationTests_Providing",
  dependencies: [
         // Use a range so hopefully this never needs updating...
        .Package(url: "../../..", versions: Version(0,0,0)..<Version(100,0,0)),
    ]
)
