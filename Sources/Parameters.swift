public class Parameters {
    private var sql : String;
    private var values : [String : String] = [String : String]();
    private var needEncdode : [String : Bool] = [String : Bool]();

    public init(sql : String) {
        self.sql = sql;
    }

    public init(sql : String, values : [String?]?) {
        self.sql = sql;

        // ToDo
        if (values != nil) {
            for (key, value) in values!.enumerated() {
                bind(key : String(key), value : value);
            }
        }
    }

    public func bind(key : String, value : Int) {
        values[key] = String(value);
        needEncdode[key] = false;
    }

    public func bind(key : String, value : UInt) {
        values[key] = String(value);
        needEncdode[key] = false;
    }

    public func bind(key : String, value : Int64) {
        values[key] = String(value);
        needEncdode[key] = false;
    }

    public func bind(key : String, value : UInt64) {
        values[key] = String(value);
        needEncdode[key] = false;
    }

    public func bind(key : String, value : Int32) {
        values[key] = String(value);
        needEncdode[key] = false;
    }

    public func bind(key : String, value : UInt32) {
        values[key] = String(value);
        needEncdode[key] = false;
    }

    public func bind(key : String, value : Int16) {
        values[key] = String(value);
        needEncdode[key] = false;
    }

    public func bind(key : String, value : UInt16) {
        values[key] = String(value);
        needEncdode[key] = false;
    }

    public func bind(key : String, value : Int8) {
        values[key] = String(value);
        needEncdode[key] = false;
    }

    public func bind(key : String, value : UInt8) {
        values[key] = String(value);
        needEncdode[key] = false;
    }

    public func bind(key : String, value : Bool) {
        values[key] = (value) ? "1" : "0";
        needEncdode[key] = false;
    }

    public func bind(key : String, value : String?) {
        if (value == nil) {
            values[key] = "null";
            needEncdode[key] = false;
        } else {
            values[key] = value;
            needEncdode[key] = true;
        }
    }

    public func toSql(conn : Connection) -> String {
        var nsql = sql;
        for (key, value) in values {
            let b = needEncdode[key];
            if ((b != nil) && (b!)) {
                nsql = nsql.replace(pattern : "\\{\(key)\\}", template : "\"" + conn.escape(value : value) + "\"");
            } else {
                nsql = nsql.replace(pattern : "\\{\(key)\\}", template : value);
            }
        }

        return nsql;
    }
}
