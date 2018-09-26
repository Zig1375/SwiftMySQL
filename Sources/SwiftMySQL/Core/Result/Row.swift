import Foundation

public struct Row {
    private(set) var order: [String];
    private(set) var map = [String: MysqlValue]();
    private(set) var userMap = [String: Any]();

    public subscript(key: String) -> MysqlValue? {
        get {
            return self.map[key]
        }
        set {
            self.userMap[key] = newValue;
        }
    }

    public init(order: [String]) {
        self.order = order;
    }

    mutating public func add(key: String, value: MysqlValue) {
        self.map[name] = value;
    }

    mutating public func addCustom(key: String, value: Any) {
        self.userMap[key] = value;

        if (!self.order.contains(key)) {
            self.order.append(key);
        }
    }

    public var description : String {
        var result = [String]();
        for (key, val) in self {
            result.append("\"\(key)\" : \"\(val)\"");
        }

        return result.joined(separator: ", ");
    }

    public func iterate(_ closure: (String, Any) -> Void) {
        for key in self.order {
            if let val = self.userMap[key] {
                closure(key, val);
            } else if let val = self.map[key], let v = val.get() {
                closure(key, v);
            }
        }
    }
}

extension Row : Sequence {
    public func makeIterator() -> AnyIterator<(String, MysqlValue)> {
        var index = 0
        return AnyIterator({ () -> (String, MysqlValue)? in
            if index >= self.order.count {
                return nil
            } else {
                let key = self.order[index]
                index += 1
                return (key, self.map[key]!)
            }
        })
    }
}