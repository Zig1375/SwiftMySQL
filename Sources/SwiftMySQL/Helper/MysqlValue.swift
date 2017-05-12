import Foundation;
import CMySQL;

public struct MysqlValue: CustomStringConvertible {
    public let data: [UInt8]?;
    private let type : enum_field_types;

    public init(data : [UInt8]?, type : enum_field_types) {
        self.data = data;
        self.type = type;
    }

    public func get() -> Any? {
        switch type {
            case MYSQL_TYPE_NULL:
                return nil;

            case MYSQL_TYPE_FLOAT,
                 MYSQL_TYPE_DOUBLE:
                return self.double;

            case MYSQL_TYPE_TINY,
                 MYSQL_TYPE_SHORT,
                 MYSQL_TYPE_LONG,
                 MYSQL_TYPE_INT24,
                 MYSQL_TYPE_LONGLONG:
                return self.integer;

            case MYSQL_TYPE_TIMESTAMP,
                 MYSQL_TYPE_DATE,
                 MYSQL_TYPE_TIME,
                 MYSQL_TYPE_DATETIME,
                 MYSQL_TYPE_YEAR,
                 MYSQL_TYPE_NEWDATE:
                return self.date;

            case MYSQL_TYPE_DECIMAL,
                 MYSQL_TYPE_NEWDECIMAL:
                return self.double;

            case MYSQL_TYPE_TINY_BLOB,
                 MYSQL_TYPE_MEDIUM_BLOB,
                 MYSQL_TYPE_LONG_BLOB,
                 MYSQL_TYPE_BLOB:
                return self.binary;

            default:
                return self.string;
        }
    }

    public var float: Float? {
        guard let string = string else {
            return nil;
        }

        return Float(string);
    }

    public var double: Double? {
        guard let string = string else {
            return nil;
        }

        return Double(string);
    }

    public var boolean: Bool? {
        guard let string = string else {
            return nil;
        }

        switch string {
            case "TRUE", "True", "true", "yes", "1", "t", "y":
                return true;
            case "FALSE", "False", "false", "no", "0", "f", "n":
                return false;
            default:
                return nil;
        }
    }

    public var integer: Int? {
        guard let string = string else {
            return nil;
        }

        return Int(string);
    }

    public var string: String? {
        guard (data != nil) else {
            return nil;
        }

        return String(bytes : data!, encoding : String.Encoding.utf8);
    }

    public var binary : [UInt8]? {
        return data
    }

    public var date : Date? {
        guard let string = string else {
            return nil;
        }

        let formatter = DateFormatter();

        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.locale = Locale(identifier : "en_US");

        return formatter.date(from: string);
    }

    public var description: String {
        return string ?? "Not representable"
    }
}
