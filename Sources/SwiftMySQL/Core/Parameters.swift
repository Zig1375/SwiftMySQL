import Foundation

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

    public func bind(key : String, value : Int?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            values[key] = String(value!);
        }

        needEncdode[key] = false;
    }

    public func bind(key : String, value : UInt?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            values[key] = String(value!);
        }

        needEncdode[key] = false;
    }

    public func bind(key : String, value : Int64?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            values[key] = String(value!);
        }

        needEncdode[key] = false;
    }

    public func bind(key : String, value : UInt64?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            values[key] = String(value!);
        }

        needEncdode[key] = false;
    }

    public func bind(key : String, value : Int32?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            values[key] = String(value!);
        }

        needEncdode[key] = false;
    }

    public func bind(key : String, value : UInt32?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            values[key] = String(value!);
        }

        needEncdode[key] = false;
    }

    public func bind(key : String, value : Int16?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            values[key] = String(value!);
        }

        needEncdode[key] = false;
    }

    public func bind(key : String, value : UInt16?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            values[key] = String(value!);
        }

        needEncdode[key] = false;
    }

    public func bind(key : String, value : Int8?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            values[key] = String(value!);
        }

        needEncdode[key] = false;
    }

    public func bind(key : String, value : UInt8?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            values[key] = String(value!);
        }

        needEncdode[key] = false;
    }

    public func bind(key : String, value : Bool?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            values[key] = ( value! ) ? "1" : "0";
        }

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

    public func bind(key : String, value : Date?) {
        if (value == nil) {
            values[key] = "null";
        } else {
            let formatter = DateFormatter();
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
            formatter.locale = Locale(identifier: "en_US");

            values[key] = "\"" + formatter.string(from: value!) + "\"";
        }

        needEncdode[key] = false;
    }

    public func bind(key : String) {
        values[key] = "null";
        needEncdode[key] = false;
    }

    public func toSql(conn : Connection) -> String {
        var nsql = sql;
        for (key, value) in values {
            let b = needEncdode[key];
            if ((b != nil) && (b!)) {
                nsql = nsql.replace(pattern : "\\{\(key)\\}", template : "'" + conn.escape(value : conn.escape(value : value)).replace(pattern : "\\\\\\\\\\\\\"", template : "\"") + "'");
            } else {
                nsql = nsql.replace(pattern : "\\{\(key)\\}", template : value);
            }
        }

        return nsql;
    }
}
