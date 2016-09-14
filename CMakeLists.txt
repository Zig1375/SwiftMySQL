project(SwiftMySQL)
add_custom_target(SwiftMySQL
        COMMAND /usr/bin/swift build -Xcc -fblocks -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        SOURCES Sources Package.swift)