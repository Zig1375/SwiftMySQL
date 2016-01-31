import Foundation

public class Pool {
    private let lock = NSLock();
    private var config : ConnectionConfig;
    private var pool : [Connection] = [Connection]();
    private var countPool : UInt = 0;
    private let connectionLimit : UInt;

    public init(config : ConnectionConfig, connectionLimit : UInt = 100) {
        self.config = config;
        self.connectionLimit = max(1, connectionLimit);
    }

    func getConnection() -> Connection? {
        defer {
            self.lock.unlock();
        }

        self.lock.lock();
        if (pool.count == 0) {
            if (countPool < connectionLimit) {
                let conn = Connection(config : self.config);
                countPool += 1;
                return conn;
            } else {
                return nil;
            }
        }

        let p = pool.removeAtIndex(0);

        if (!p.ping()) {
            // DISCONNECTED
            countPool -= 1;
            self.lock.unlock();
            return getConnection();
        }

        return p;
    }

    func release(conn : Connection) {
        self.lock.lock();
        pool.append(conn);
        self.lock.unlock();
    }
/*
    public func query(sql : String, values : [String?]? = nil) throws -> Result {
        let conn = getConnection();
        let result = try conn.query(sql, values : values);
        release(conn);

        return result;
    }

    public func query(p : Parameters) throws -> Result {
        let conn = getConnection();
        let result = try conn.query(p);
        release(conn);

        return result;
    }

    public func execute(sql : String, values : [String?]? = nil) throws {
        let conn = getConnection();
        try conn.execute(sql, values : values);
        release(conn);
    }

    public func execute(p : Parameters) throws {
        let conn = getConnection();
        try conn.execute(p);
        release(conn);
    }

    public func fetchRow(sql : String, values : [String?]? = nil) throws -> Row? {
        let conn = getConnection();
        let result = try conn.fetchRow(sql, values : values);
        release(conn);

        return result;
    }

    public func fetchRow(p : Parameters) throws -> Row? {
        let conn = getConnection();
        let result = try conn.fetchRow(p);
        release(conn);

        return result;
    }

    public func fetchAll(sql : String, values : [String?]? = nil) throws -> [Row] {
        let result = try query(sql, values : values);

        var res = [Row]();
        while let row = result.fetch() {
            res.append(row);
        }

        return res;
    }

    public func fetchAll(p : Parameters) throws -> [Row] {
        let result = try query(p);

        var res = [Row]();
        while let row = result.fetch() {
            res.append(row);
        }

        return res;
    }
*/
}
