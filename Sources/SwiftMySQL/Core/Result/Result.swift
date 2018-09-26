import Foundation
import CMySQL;
#if os(Linux)
import Glibc
#else
import Darwin
#endif

public class Result {
    private let connection : Connection;
    private let mysql_conn : UnsafeMutablePointer<st_mysql>;
    private var result : UnsafeMutablePointer<st_mysql_res>?;
    private var lastFields : [Field]?;
    private var lastFieldsOrder: [String] = [String]();
    private var isFinished : Bool = false;
    private var released : Bool = false;
    public let sql : String;

    init(connection : Connection, mysql_conn : UnsafeMutablePointer<st_mysql>, result : UnsafeMutablePointer<st_mysql_res>, sql : String) {
        self.connection = connection;
        self.mysql_conn = mysql_conn;
        self.result = result
        self.sql = sql;
    }

    deinit {
        release();
    }

    public func release() {
        if (!released) {
            released = true;
            while (nextRowset()) {};
            clear();
        }
    }

    public func count() -> Int {
        guard (self.result != nil) else {
            return 0;
        }

        return Int(mysql_num_rows(self.result!));
    }

    public func nextRowset() -> Bool {
        guard (!isFinished) else {
            return false;
        }

        clear();
        if (mysql_next_result(self.mysql_conn) > 0) {
            isFinished = true;
            return false;
        }

        let t = mysql_store_result(self.mysql_conn);
        if (t == nil) {
            return false;
        }

        self.result = t;
        return true;
    }

    public func fetch() -> Row? {
        guard (self.result != nil) else {
            return nil;
        }

        if let row = mysql_fetch_row(self.result!) {
            let fields = self.fields();
            var result = Row(order: self.lastFieldsOrder);

            if let lengths = mysql_fetch_lengths(self.result!) {

                for ( index, field ) in fields.enumerated() {
                    if let val = row[index] {
                        if (field.type == MysqlFieldType.MYSQL_BINARY) {
                            let data = Data(bytes: UnsafeRawPointer(val), count: Int(lengths[index]));
                            result.add(key: field.name, value: MysqlValue(data: data, type : field.type));
                        } else {
                            let str = String(validatingUTF8: val) ?? "";
                            result.add(key: field.name, value: MysqlValue(string: str, type : field.type));
                        }
                    } else {
                        result.add(key: field.name, value: MysqlValue(data: nil, type : field.type));
                    }
                }
            }

            return result;
        }

        return nil;
    }

    private func clear() {
        guard (self.result != nil) else {
            return;
        }

        mysql_free_result(self.result!);
        self.lastFields = nil;
        self.result = nil;
    }

    public func fields() -> [Field] {
        guard (self.result != nil) else {
            return [Field]();
        }

        if (self.lastFields != nil) {
            return self.lastFields!;
        }

        self.lastFields = [Field]();
        self.lastFieldsOrder = [String]();

        let cnt = mysql_num_fields(self.result!);
        for i in 0..<cnt {
            let field = Field(pointer : mysql_fetch_field_direct(self.result!, i));
            self.lastFields!.append( field );
            self.lastFieldsOrder.append(field.name);
        }

        return self.lastFields!;
    };

    private func getText(buf : UnsafePointer<Int8>) -> String {
        if let utf8String = String.init(validatingUTF8 : buf) {
            return utf8String;
        }

        return "";
    }
}
