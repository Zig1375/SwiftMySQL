import Foundation;

public struct MysqlValue: CustomStringConvertible {
    public let data: [UInt8]?;

    public init(data : [UInt8]?) {
        self.data = data;
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

        return String(bytes : data!, encoding : NSUTF8StringEncoding);
    }

    public var binary : [UInt8]? {
        return data
    }

    public var date : NSDate? {
        guard let string = string else {
            return nil;
        }

        let formatter = NSDateFormatter();

        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.locale = NSLocale(localeIdentifier : "en_US");

#if os(Linux)
        return formatter.dateFromString(string);
#elseif os(OSX)
        return formatter.date(from: string);
#endif
    }

    public var description: String {
        return string ?? "Not representable"
    }
}
