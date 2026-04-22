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
         url: "https://github.com/Nets-mobile-acceptance/Netaxept-iOS-SDK/releases/download/2.7.5/Pia.xcframework.zip",
         checksum: "29135ab9e45ac2fe157dc3d981a202aa638910e5111eb2e139702d7710162f38"
      )
   ]
)
