// swift-tools-version:5.1

import PackageDescription

let package = Package(
  
  name: "CoreDataToSwiftUI",
  
  platforms: [
    .macOS(.v10_15), .iOS(.v13), .watchOS(.v6)
  ],
  
  products: [
    .library(name: "DirectToSwiftUI", targets: [ "DirectToSwiftUI" ])
  ],
  
  dependencies: [
    .package(url: "https://github.com/DirectToSwift/SwiftUIRules.git",
             from: "0.1.3")
  ],
  
  targets: [
    .target(name: "DirectToSwiftUI", 
            dependencies: [ "SwiftUIRules" ])
  ]
)
