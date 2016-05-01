project(MySQL)
add_custom_target(MySQL
        COMMAND /Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2016-04-25-a.xctoolchain/usr/bin/swift build -Xcc -fblocks -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        SOURCES Sources Package.swift)