public class Query {
    let connection : Connection;
    public var sql : String;
    public var values : [String : String] = [String : String]();

    init(connection : Connection, sql : String, value : [String]?) {
        self.sql = sql;
        self.connection = connection;

        // ToDo
        if (value != nil) { print("Has Value") }
    }

    public func bind(key : String, value : Int) {
        values[key] = String(value);
    }

    public func bind(key : String, value : UInt) {
        values[key] = String(value);
    }

    public func bind(key : String, value : Int64) {
        values[key] = String(value);
    }

    public func bind(key : String, value : UInt64) {
        values[key] = String(value);
    }

    public func bind(key : String, value : Int32) {
        values[key] = String(value);
    }

    public func bind(key : String, value : UInt32) {
        values[key] = String(value);
    }

    public func bind(key : String, value : Int16) {
        values[key] = String(value);
    }

    public func bind(key : String, value : UInt16) {
        values[key] = String(value);
    }

    public func bind(key : String, value : Int8) {
        values[key] = String(value);
    }

    public func bind(key : String, value : UInt8) {
        values[key] = String(value);
    }

    public func bind(key : String, value : Bool) {
        values[key] = (value) ? "\"true\"" : "\"false\"";
    }

    public func bind(key : String, value : String?) {
        if (value == "nil") {
            values[key] = "null";
        } else {
            values[key] = "\"" + self.connection.escape(value!) + "\"";
        }
    }

    public func toSql() -> String {
        if (values.count == 0) {
            return sql;
        }

        var nsql : String = sql;
        for (key, value) in values {
            nsql = replace(nsql, search : ":\(key)", replacement : value);
        }

        return nsql;
    }

    private func replace(st : String, search : String, replacement : String) -> String {
        return st;
        // ToDo Now Sting has no method stringByReplacingOccurrencesOfString is Swift 2.2
        // return st.stringByReplacingOccurrencesOfString(search, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}
