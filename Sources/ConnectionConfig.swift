import CMySQL;

public class ConnectionConfig {
    public var host : String;
    public var port : UInt32;
    public var user : String;
    public var password : String;
    public var database : String;
    public var flags : Flags;

    public struct Flags : OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        static let None = 0

        static let Compress = CLIENT_COMPRESS
        static let FoundRows = CLIENT_FOUND_ROWS
        static let IgnoreSigPipe = CLIENT_IGNORE_SIGPIPE
        static let IgnoreSpace = CLIENT_IGNORE_SPACE
        static let Interactive = CLIENT_INTERACTIVE
        static let LocalFiles = CLIENT_LOCAL_FILES
        static let MultiResults = CLIENT_MULTI_RESULTS
        static let MultiStatements = CLIENT_MULTI_STATEMENTS
        static let NoSchema = CLIENT_NO_SCHEMA
        static let ODBC = CLIENT_ODBC
        static let SSL = CLIENT_SSL
        static let RememberOptions = CLIENT_REMEMBER_OPTIONS
    }


    public init(host: String, database: String, port: UInt32 = UInt32(MYSQL_PORT), user: String = "", password: String = "", flags: Flags = Flags(rawValue: 0)) {
        self.host = host;
        self.user = user;
        self.password = password;
        self.database = database;
        self.port = UInt32(port);
        self.flags = flags;
    }
}
