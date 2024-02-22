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
         checksum: "06b15383b28b7f4a369522093a1d9dc222ec8ebf685da6f7eed511f019a73544"
      )
   ]
)
