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
         checksum: "c21f18f47ebc06ee7e380f71adde16947b066df67115bbf8c6af855e753c0dc0"
      )
   ]
)
