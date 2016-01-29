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

    public var isUnsigned : Bool {
        get {
            return (self.flags & (1 << 5) != 0)
        }
    }

    init(pointer: UnsafePointer<MYSQL_FIELD>) {
        self.name = String.fromCString(pointer.memory.name)!
        self.originalName = String.fromCString(pointer.memory.org_name)!
        self.table = String.fromCString(pointer.memory.table)!
        self.originalTable = String.fromCString(pointer.memory.org_table)!
        self.database = String.fromCString(pointer.memory.db)!
        self.catalog = String.fromCString(pointer.memory.catalog)!
        self.length = pointer.memory.length
        self.maxLength = pointer.memory.max_length
        self.flags = pointer.memory.flags;
        self.decimals = pointer.memory.decimals;
    }
}
