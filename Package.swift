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
         checksum: "e4e3f99400b80d9e646dc44ef9058968d9ac88571db1dd8a16d1ad34f149fd96"
      )
   ]
)
