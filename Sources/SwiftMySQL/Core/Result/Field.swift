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

    public let type : enum_field_types;

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
        self.type = pointer.pointee.type;
    }
}
