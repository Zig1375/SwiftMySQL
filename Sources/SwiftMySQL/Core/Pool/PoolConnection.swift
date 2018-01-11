import Foundation

public class PoolConnection : Connection {
    let expire : Date;
    let poolManager : Pool;

    init(config : ConnectionConfig, poolManager : Pool, poolLifeTime : UInt = 60) {
        self.expire = Date().addingTimeInterval(TimeInterval(poolLifeTime));

        self.poolManager = poolManager;
        super.init(config : config);
    }

    deinit {
        close();
        self.poolManager.poolClosed();
    }

    func isLife() -> Bool {
        if (self.state == .DISCONNECTED) {
            return false;
        }

        let compare = NSDate().compare(self.expire);
        let result : Bool = ((compare == .orderedAscending) && (self.ping()));

        if (!result) {
            self.close();
        }

        return result;
    }
}
