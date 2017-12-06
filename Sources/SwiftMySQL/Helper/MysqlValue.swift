import Foundation;

public struct MysqlValue: CustomStringConvertible {
    public let data: Data?;
    public let str : String?;
    public let type : MysqlFieldType;

    public init(data : Data?, type : MysqlFieldType) {
        self.data = data;
        self.str  = nil;
        self.type = type;
    }

    public init(string : String, type : MysqlFieldType) {
        self.str  = string;
        self.data = nil;
        self.type = type;
    }

    public func get() -> Any? {
        switch type {
        case MysqlFieldType.MYSQL_NULL:
            return nil;

        case MysqlFieldType.MYSQL_DOUBLE :
            return self.double;

        case MysqlFieldType.MYSQL_INTEGER :
            return self.integer;

        case MysqlFieldType.MYSQL_DATE :
            return self.date;

        case MysqlFieldType.MYSQL_BINARY :
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
        guard (self.str != nil) else {
            return nil;
        }

        return self.str;
    }

    public var binary : Data? {
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
