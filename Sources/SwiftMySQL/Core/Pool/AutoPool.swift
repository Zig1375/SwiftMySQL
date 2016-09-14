import Foundation

public typealias DBResultCallback = (Result?, MysqlDebug?) -> Void
public typealias DBRowCallback = (Row?, MysqlDebug?) -> Void

class AutoPool {
    private let pool : Pool;

    init(config : ConnectionConfig, connectionLimit : UInt = 100, poolLifeTime : UInt = 60) {
        self.pool = Pool(config : config, connectionLimit : connectionLimit, poolLifeTime : poolLifeTime);
    }

    func query(_ sql : String, _ callback : DBResultCallback? = nil) {
        if let conn = self.pool.getConnection() {
            defer {
                self.pool.release(conn);
            }

            do {
                let result = try conn.query(sql : sql);
                callback?(result, MysqlDebug(sql : sql));
                return;
            } catch MysqlError.Error(let error, let errno) {
                callback?(nil, MysqlDebug(sql : sql, errno: errno, error : error));
                return;
            } catch {

            }
        }

        callback?(nil, MysqlDebug(sql : sql));
    }

    func query(_ p : Parameters, _ callback : DBResultCallback? = nil) {
        if let conn = self.pool.getConnection() {
            defer {
                self.pool.release(conn);
            }

            let sql = p.toSql(conn : conn);
            self.query(sql, callback);
            return;
        }

        callback?(nil, nil);
    }



    func fetchRow(_ sql : String, _ callback : DBRowCallback? = nil) {
        self.query(sql) {result, debug in
            if (result == nil) {
                callback?(nil, debug);
                return;
            }

            callback?(result?.fetch(), debug);
        }
    }

    func fetchRow(_ p : Parameters, _ callback : DBRowCallback? = nil) {
        self.query(p) {result, debug in
            if (result == nil) {
                callback?( nil, debug);
                return;
            }

            callback?(result?.fetch(), debug);
        }
    }
}
