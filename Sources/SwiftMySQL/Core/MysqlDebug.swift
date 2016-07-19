import Foundation

public struct MysqlDebug : CustomStringConvertible {
    public let error : String?;
    public let errno : UInt32?;
    public let sql : String;

    init(sql : String, errno : UInt32? = nil, error : String? = nil) {
        self.sql = sql;
        self.errno = errno;
        self.error = error;
    }

    public var description : String {
        if (self.error != nil) {
            return "\(sql) => \(self.error!) (\(self.errno!))";
        }

        return "\(sql)";
    }
}
