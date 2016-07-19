import Foundation

public typealias DBResultCallback = (result : Result?, debug : MysqlDebug?) -> Void
public typealias DBRowCallback = (row : Row?, debug : MysqlDebug?) -> Void

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
                callback?(result : result, debug : MysqlDebug(sql : sql));
                return;
            } catch MysqlError.Error(let error, let errno) {
                callback?(result : nil, debug : MysqlDebug(sql : sql, errno: errno, error : error));
                return;
            } catch {

            }
        }

        callback?(result : nil, debug : MysqlDebug(sql : sql));
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

        callback?(result : nil, debug : nil);
    }



    func fetchRow(_ sql : String, _ callback : DBRowCallback? = nil) {
        self.query(sql) {result, debug in
            if (result == nil) {
                callback?(row : nil, debug : debug);
                return;
            }

            callback?(row : result?.fetch(), debug : debug);
        }
    }

    func fetchRow(_ p : Parameters, _ callback : DBRowCallback? = nil) {
        self.query(p) {result, debug in
            if (result == nil) {
                callback?(row : nil, debug : debug);
                return;
            }

            callback?(row : result?.fetch(), debug : debug);
        }
    }
}
