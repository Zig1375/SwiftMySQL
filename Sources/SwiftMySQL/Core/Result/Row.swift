import Foundation

public struct Row {
    public let order: [String];
    private(set) var map = [String: MysqlValue]();

    public subscript(key: String) -> MysqlValue? {
        get {
            return self.map[key]
        }
        set {
            self.map[key] = newValue;
        }
    }

    public init(order: [String]) {
        self.order = order;
    }

    mutating public func add(name: String, value: MysqlValue) {
        self.map[name] = value;
    }

    public var description : String {
        var result = [String]();
        for (key, val) in self {
            result.append("\"\(key)\" : \"\(val)\"");
        }

        return result.joined(separator: ", ");
    }
}

extension Row : Sequence {
    public func makeIterator() -> AnyIterator<(String, MysqlValue)> {
        var index = 0
        return AnyIterator({ () -> (String, MysqlValue)? in
            if index >= self.order.count {
                return nil
            }
            else {
                let key = self.order[index]
                index += 1
                return (key, self.map[key]!)
            }
        })
    }
}