import Foundation

public class PoolConnection : Connection {
    let expire : NSDate;
    let poolManager : Pool;

    override init(config : ConnectionConfig, poolManager : Pool) {
        self.expire = NSDate().addingTimeInterval(60);
        self.poolManager = poolManager;
        super.init(config : config);
    }

    override deinit {
        close();
        self.poolManager.poolClosed();
    }

    func isLife() -> Bool {
        if (self.state == .DISCONNECTED) {
            return false;
        }

        let compare = NSDate().compare(self.expire);
        let result : Bool;
#if os(Linux)
        result = (compare == .OrderedDescending);
#elseif os(OSX)
        result = (compare == .orderedDescending);
#endif

        if ((!result) || (!self.ping())) {
            self.close();
        }

        return result;
    }
}
