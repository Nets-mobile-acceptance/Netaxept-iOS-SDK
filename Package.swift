// swift-tools-version: 5.7

import PackageDescription

let package = Package(
   name: "Netaxept-iOS-SDK",
   products: [
      .library(name: "Pia", targets: ["Pia"])
   ],
   targets: [
      .binaryTarget(
         name: "Pia",
         url: "https://github.com/Nets-mobile-acceptance/Netaxept-iOS-SDK/releases/download/2.7.7/Pia.xcframework.zip",
         checksum: "5e43114d4441cdd2c61056223d5d3c63d9d6dc03a0cc0ef0d616367495ece633"
      )
   ]
)
