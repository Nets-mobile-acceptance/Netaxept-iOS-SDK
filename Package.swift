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
         url: "https://github.com/Nets-mobile-acceptance/Netaxept-iOS-SDK/releases/download/2.7.6/Pia.xcframework.zip",
         checksum: "b55a106c8773f1a73cc8df4b0b56a04d6100de0a1954500bb51f85ed95578747"
      )
   ]
)
