import PackageDescription

let package = Package(
  name:         "MySQL",
  targets:      [],
  dependencies: [
      .Package(url: "https://github.com/Zig1375/CMySQL.git", majorVersion: 1)
  ]
)
