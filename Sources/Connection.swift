import Foundation;
import CMySQL;

public class Connection {
    private var config : ConnectionConfig;
    private var connectCalled : Bool = false;
    private var state : ConnectionState = ConnectionState.DISCONNECTED;
    private let connection : UnsafeMutablePointer<st_mysql>;

    init(config : ConnectionConfig) {
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
            throw MysqlError.Error(error : getText(mysql_error(self.connection)), errno : mysql_errno(self.connection));
        }

        self.state = ConnectionState.CONNECTED;
    }

    public func getCharacterName() throws -> String {
        if (self.state != ConnectionState.CONNECTED) {
            throw MysqlError.NotConnected;
        }

        return getText(mysql_character_set_name(self.connection));
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
        try execute("START TRANSACTION");
    }

    public func commit() throws {
        try execute("COMMIT");
    }

    public func rollback() throws {
        try execute("ROLLBACK");
    }

    public func close() {
        self.state = ConnectionState.DISCONNECTED;

        ///mysql_close(MYSQL *sock);
        mysql_close(self.connection);
    }

    public func escape(value : String) -> String {
        let readBuffer  = UnsafeMutablePointer<CChar>.alloc(4098)
        let status = mysql_real_escape_string(self.connection, readBuffer, value, UInt(value.characters.count));

        defer {
            readBuffer.destroy();
            readBuffer.dealloc(4098);
       }

        if (status > 0) {
            return getText(readBuffer);
        } else {
            return "";
        }
    }


    public func prepare(sql : String, values : [String]? = nil) -> String {
        if (values == nil) {
            return sql;
        }

        // ToDo
        return sql;
    }

    public func query(sql : String, values : [String]? = nil) throws -> Result {
        try execute(sql, values : values);

        let result = mysql_store_result(self.connection);
        if (result == nil) {
            throw MysqlError.Error(error : getText(mysql_error(self.connection)), errno : mysql_errno(self.connection));
        }

        return Result(connection : self, mysql_conn : self.connection, result : result);
    }

    public func execute(sql : String, values : [String]? = nil) throws {
        if (self.state != ConnectionState.CONNECTED) {
            throw MysqlError.NotConnected;
        }

        /// mysql_query(MYSQL *mysql, const char *q);
        if (mysql_query(self.connection,  prepare(sql, values : values)) == 1) {
            throw MysqlError.Error(error : getText(mysql_error(self.connection)), errno : mysql_errno(self.connection));
        }
    }


    public func fetchRow(sql : String, values : [String]? = nil) throws -> [String : Value]? {
        let result = try query(sql, values : values);
        let row = result.fetch();
        result.clear();

        return row;
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
        return getText(mysql_error(self.connection));
    }

    public func sqlState() throws -> String? {
        if (self.state != ConnectionState.CONNECTED) {
            throw MysqlError.NotConnected;
        }

        return getText(mysql_sqlstate(self.connection));
    }

    public func sslSet(key : String, cert : String, ca : String, capath : String, cipher : String) -> Bool {
        return (mysql_ssl_set(self.connection, key, cert, ca, capath, cipher) > 0);
    }

    public func sslGet() -> String {
        return getText(mysql_get_ssl_cipher(self.connection));
    }

    public func ping() throws -> Bool {
        if (self.state != ConnectionState.CONNECTED) {
            throw MysqlError.NotConnected;
        }

        if (mysql_ping(self.connection) > 0) {
            self.state = ConnectionState.DISCONNECTED;
            return false;
        }

        return true;
    }

    private func getText(buf : UnsafePointer<Int8>) -> String {
        if let utf8String = String.fromCString(buf) {
            return utf8String;
        }

        return "";
    }
}
