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
         checksum: "82638b6c966beff8d68fcfecac173c471ed50b16607e97bbc94b6f72e9f3d3ef"
      )
   ]
)
