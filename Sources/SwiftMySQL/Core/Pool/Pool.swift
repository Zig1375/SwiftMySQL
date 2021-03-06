import Foundation

public class Pool {
    private let _lock = NSLock();

    private var config : ConnectionConfig;
    private var pool : [PoolConnection] = [PoolConnection]();
    private var countPool : UInt = 0;
    private let connectionLimit : UInt;
    private let poolLifeTime : UInt;

    public init(config : ConnectionConfig, connectionLimit : UInt = 100, poolLifeTime : UInt = 60) {
        self.config = config;
        self.connectionLimit = max(1, connectionLimit);
        self.poolLifeTime = max(10, poolLifeTime);

        zThread(block : {
            while(true) {
                sleep(5);

                self._lock.lock();

                let len = self.pool.count;
                for index in stride(from: len - 1, to: 0, by: -1) {
                    if (!self.pool[index].isLife()) {
                        self.pool.remove(at: index);
                    }
                }

                self._lock.unlock();
            }
        }).start();
    }

    public func getConnection() -> PoolConnection? {
        defer {
            self._lock.unlock();
        }

        self._lock.lock();
        return self.poolConnection();
    }

    func poolClosed() {
        countPool -= 1;
    }

    private func poolConnection() -> PoolConnection? {
        if (pool.count == 0) {
            if (countPool < connectionLimit) {
                countPool += 1;
                let conn = PoolConnection(config : self.config, poolManager : self, poolLifeTime : self.poolLifeTime);
                if let _ = try? conn.connect() {
                    return conn;
                }
            } else {
                // Уперлись в лимит
                return nil;
            }
        }

        let pc = pool.remove(at : 0);

        if (!pc.isLife()) {
            // Pool сдох, выдаем следующий
            return poolConnection();
        }

        return pc;
    }

    public func release(_ conn : PoolConnection) {
        if (conn.isLife()) {
            self._lock.lock();
            self.pool.append(conn);
            self._lock.unlock();
        }
    }
}
