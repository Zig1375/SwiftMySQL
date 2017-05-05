import PackageDescription

let package = Package(
  name:         "SwiftMySQL",
  targets:      [],
  dependencies: []
)

#if os(OSX)
    package.dependencies.append(.Package(url: "https://github.com/Zig1375/CMySQLosx.git", majorVersion: 1, minor : 1));
#elseif os(Linux)
    package.dependencies.append(.Package(url: "https://github.com/Zig1375/CMySQL.git", majorVersion: 1, minor : 1));
#endif