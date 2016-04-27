import Foundation;
import CMySQL;

public class Connection {
    private var config : ConnectionConfig;
    private var connectCalled : Bool = false;
    private(set) var state : ConnectionState = ConnectionState.DISCONNECTED;
    private let connection : UnsafeMutablePointer<st_mysql>;

    public init(config : ConnectionConfig) {
        self.config = config;
        self.connection  = mysql_init(nil);
    }

    deinit {
        close()
    }

    public func connect() throws {
        if (self.state == ConnectionState.CONNECTED) {
            throw MysqlError.AlreadyConnected;
        }

        if (mysql_real_connect(self.connection, config.host, config.user, config.password, config.database, config.port, nil, config.flags.rawValue) == nil) {
            throw MysqlError.Error(error : getText(buf : mysql_error(self.connection)), errno : mysql_errno(self.connection));
        }

        self.state = ConnectionState.CONNECTED;
    }

    public func getCharacterName() throws -> String {
        if (self.state != ConnectionState.CONNECTED) {
            throw MysqlError.NotConnected;
        }

        return getText(buf : mysql_character_set_name(self.connection));
    }

    public func setCharacterName(charset : String) throws -> Bool {
        if (self.state != ConnectionState.CONNECTED) {
            throw MysqlError.NotConnected;
        }

        let status = mysql_set_character_set(self.connection, charset);
        return (status == 0);
    }

    public func selectDB(db : String) throws -> Bool {
        if (self.state != ConnectionState.CONNECTED) {
            throw MysqlError.NotConnected;
        }

        let status = mysql_select_db(self.connection, db);

        if (status == 0) {
            config.database = db;
            return true;
        }

        return false;
    }

    public func beginTransaction() throws {
        try execute(sql : "START TRANSACTION");
    }

    public func commit() throws {
        try execute(sql : "COMMIT");
    }

    public func rollback() throws {
        try execute(sql : "ROLLBACK");
    }

    public func close() {
        if (self.state != .DISCONNECTED) {
            self.state = ConnectionState.DISCONNECTED;

            ///mysql_close(MYSQL *sock);
            mysql_close(self.connection);
        }
    }

    public func escape(value : String) -> String {
        let readBuffer  = UnsafeMutablePointer<CChar>(allocatingCapacity : 4098)
        let status = mysql_real_escape_string(self.connection, readBuffer, value, UInt(value.characters.count));

        defer {
            readBuffer.deinitialize(count : 4098);
       }

        if (status > 0) {
            return getText(buf : readBuffer);
        } else {
            return "";
        }
    }

    public func query(sql : String, values : [String?]? = nil) throws -> Result {
        try execute(sql : sql, values : values);

        let result = mysql_store_result(self.connection);
        if (result == nil) {
            throw MysqlError.Error(error : getText(buf : mysql_error(self.connection)), errno : mysql_errno(self.connection));
        }

        return Result(connection : self, mysql_conn : self.connection, result : result);
    }

    public func query(p : Parameters) throws -> Result {
        return try query(sql : p.toSql(conn : self));
    }

    public func execute(sql : String, values : [String?]? = nil) throws {
        if (self.state != ConnectionState.CONNECTED) {
            throw MysqlError.NotConnected;
        }

        var nsql = sql;
        if (values != nil) {
            nsql =  Parameters(sql : sql, values : values!).toSql(conn : self);
        }

        /// mysql_query(MYSQL *mysql, const char *q);
        if (mysql_query(self.connection,  nsql) == 1) {
            throw MysqlError.Error(error : getText(buf : mysql_error(self.connection)), errno : mysql_errno(self.connection));
        }
    }

    public func execute(p : Parameters) throws {
        try execute(sql : p.toSql(conn : self));
    }

    public func fetchRow(sql : String, values : [String?]? = nil) throws -> Row? {
        let result = try query(sql : sql, values : values);
        let row = result.fetch();

        return row;
    }

    public func fetchRow(p : Parameters) throws -> Row? {
        let result = try query(p : p);
        let row = result.fetch();

        return row;
    }

    public func fetchAll(sql : String, values : [String?]? = nil) throws -> [Row] {
        let result = try query(sql : sql, values : values);

        var res = [Row]();
        while let row = result.fetch() {
            res.append(row);
        }

        return res;
    }

    public func fetchAll(p : Parameters) throws -> [Row] {
        let result = try query(p : p);

        var res = [Row]();
        while let row = result.fetch() {
            res.append(row);
        }

        return res;
    }


    public func affectedRows() -> UInt64 {
        return mysql_affected_rows(self.connection);
    }

    public func insertId() -> UInt64 {
        return mysql_insert_id(self.connection);
    }





    public func mysqlErrno() -> UInt32 {
        return mysql_errno(self.connection);
    }

    public func mysqlError() -> String {
        return getText(buf : mysql_error(self.connection));
    }

    public func sqlState() throws -> String? {
        if (self.state != ConnectionState.CONNECTED) {
            throw MysqlError.NotConnected;
        }

        return getText(buf : mysql_sqlstate(self.connection));
    }

    public func sslSet(key : String, cert : String, ca : String, capath : String, cipher : String) -> Bool {
        return (mysql_ssl_set(self.connection, key, cert, ca, capath, cipher) > 0);
    }

    public func sslGet() -> String {
        return getText(buf : mysql_get_ssl_cipher(self.connection));
    }

    public func ping() -> Bool {
        if (self.state != ConnectionState.CONNECTED) {
            return false;
        }

        if (mysql_ping(self.connection) > 0) {
            self.state = ConnectionState.DISCONNECTED;
            return false;
        }

        return true;
    }

    private func getText(buf : UnsafePointer<Int8>) -> String {
        if let utf8String = String.init(validatingUTF8 : buf) {
            return utf8String;
        }

        return "";
    }
}
