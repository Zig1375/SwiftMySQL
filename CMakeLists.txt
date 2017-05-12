cmake_minimum_required(VERSION 3.7)
project(SwiftMySQL)

add_custom_target(SwiftMySQL ALL
        COMMAND /Library/Developer/Toolchains/swift-3.1-RELEASE.xctoolchain/usr/bin/swift build
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        SOURCES Sources Package.swift)
