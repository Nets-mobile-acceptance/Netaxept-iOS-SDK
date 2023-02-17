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
         url: "https://github.com/Nets-mobile-acceptance/Netaxept-iOS-SDK/raw/master/Pia.xcframework.zip",
         checksum: "cb494da865088028f7a48333f09e1e2c6d19a472521d50efdc271cbe58a6a199"
      )
   ]
)
