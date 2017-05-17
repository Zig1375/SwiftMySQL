import CMySQL;

public class Field {
    /// Name of column
    public let name : String;

    /// Original column name, if an alias
    public let originalName : String;

    /// Table of column if column was a field
    public let table : String;

    /// Org table name, if table was an alias
    public let originalTable : String;

    /// Database for table
    public let database : String;

    /// Catalog for table
    public let catalog : String;

    /// Width of column (create length)
    public let length : UInt;

    /// Max width for selected set
    public let maxLength : UInt;

    /// Div flags
    public let flags : UInt32;

    /// Number of decimals in field
    public let decimals : UInt32;

    public let type : MysqlFieldType;

    public var isUnsigned : Bool {
        get {
            return (self.flags & (1 << 5) != 0)
        }
    }

    init(pointer: UnsafePointer<MYSQL_FIELD>) {
        self.name = String.init(validatingUTF8 : pointer.pointee.name)!
        self.originalName = String.init(validatingUTF8 : pointer.pointee.org_name)!
        self.table = String.init(validatingUTF8 : pointer.pointee.table)!
        self.originalTable = String.init(validatingUTF8 : pointer.pointee.org_table)!
        self.database = String.init(validatingUTF8 : pointer.pointee.db)!
        self.catalog = String.init(validatingUTF8 : pointer.pointee.catalog)!
        self.length = pointer.pointee.length
        self.maxLength = pointer.pointee.max_length
        self.flags = pointer.pointee.flags;
        self.decimals = pointer.pointee.decimals;
        self.type = Field.getFieldType(type : pointer.pointee.type, flags : pointer.pointee.flags);
    }

    static public func getFieldType(type : enum_field_types, flags : UInt32) -> MysqlFieldType {
        switch type {
            case MYSQL_TYPE_NULL:
                return .MYSQL_NULL;

            case MYSQL_TYPE_FLOAT,
                 MYSQL_TYPE_DOUBLE:
                return .MYSQL_DOUBLE;

            case MYSQL_TYPE_TINY,
                 MYSQL_TYPE_SHORT,
                 MYSQL_TYPE_LONG,
                 MYSQL_TYPE_INT24,
                 MYSQL_TYPE_LONGLONG:
                return .MYSQL_INTEGER;

            case MYSQL_TYPE_TIMESTAMP,
                 MYSQL_TYPE_DATE,
                 MYSQL_TYPE_TIME,
                 MYSQL_TYPE_DATETIME,
                 MYSQL_TYPE_YEAR,
                 MYSQL_TYPE_NEWDATE:
                return .MYSQL_DATE;

            case MYSQL_TYPE_DECIMAL,
                 MYSQL_TYPE_NEWDECIMAL:
                return .MYSQL_DOUBLE;

            case MYSQL_TYPE_TINY_BLOB,
                 MYSQL_TYPE_MEDIUM_BLOB,
                 MYSQL_TYPE_LONG_BLOB,
                 MYSQL_TYPE_BLOB:

                if ( (flags & UInt32(BINARY_FLAG)) != 0) {
                    return .MYSQL_BINARY;
                }

                return .MYSQL_STRING;

            default:
                return .MYSQL_STRING;
        }
    }
}

public enum MysqlFieldType {
    case MYSQL_NULL;
    case MYSQL_DOUBLE;
    case MYSQL_INTEGER;
    case MYSQL_DATE;
    case MYSQL_BINARY;
    case MYSQL_STRING;
}