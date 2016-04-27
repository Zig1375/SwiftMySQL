import Foundation

public class PoolConnection : Connection {
    let expire : NSDate;

    override init(config : ConnectionConfig) {
        self.expire = NSDate().addingTimeInterval(60);
        super.init(config : config);
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
