import Foundation

#if os(Linux)
    #if swift(>=3.1)
        typealias RegularExpressionType = NSRegularExpression
    #else
        typealias RegularExpressionType = RegularExpression
    #endif
#else
    typealias RegularExpressionType = NSRegularExpression
#endif