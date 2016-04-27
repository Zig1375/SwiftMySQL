public struct Row {
    public let values : [String : Value];

    public init(values : [String : Value]) {
        self.values = values;
    }

    public subscript(field : String) -> Value? {
        return values[field];
    }
}
