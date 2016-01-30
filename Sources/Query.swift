public class Query {
    let connection : Connection;
    public var sql : String;
    public var values : [String : String] = [String : String]();
    private var readySql : String;
    private var lastCntValues : Int = 0;

    init(connection : Connection, sql : String, values : [String?]?) {
        self.sql = sql;
        self.readySql = sql;
        self.connection = connection;

        // ToDo
        if (values != nil) {
            for (key, value) in values!.enumerate() {
                bind(String(key), value : value);
            }
        }
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
        if ((lastCntValues == values.count)) {
            return self.readySql;
        }

        self.readySql = sql;
        for (key, value) in values {
            self.readySql = self.readySql.replace("\\{\(key)\\}", template : value);
        }

        lastCntValues = values.count;
        return self.readySql;
    }
}
