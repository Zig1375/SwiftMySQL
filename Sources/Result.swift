import CMySQL;
import Glibc;

public class Result {
    private let connection : Connection;
    private let mysql_conn : UnsafeMutablePointer<st_mysql>;
    private var result : UnsafeMutablePointer<st_mysql_res>?;
    private var lastFields : [Field]?;
    private var isFinished : Bool = false;

    init(connection : Connection, mysql_conn : UnsafeMutablePointer<st_mysql>, result : UnsafeMutablePointer<st_mysql_res>) {
        self.connection = connection;
        self.mysql_conn = mysql_conn;
        self.result = result
    }

    deinit {
        while(nextRowset()){};
        clear();
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

        var result: [String : Value] = [:];

        let row = mysql_fetch_row(self.result!);
        if (row == nil) {
            return nil;
        }

        let lengths = mysql_fetch_lengths(self.result!)

        for (index, field) in fields().enumerate() {
            let val = row[index]
            if (val != nil) {
                let length = Int(lengths[index]);

                var buffer = [UInt8](count: length, repeatedValue: 0);
                memcpy(&buffer, val, length);

                result[field.name] = Value(data : buffer);
            } else {
                result[field.name] = Value(data : nil);
            }
        }

        return Row(values : result);
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

        let cnt = mysql_num_fields(self.result!);
        for i in 0..<cnt {
            self.lastFields!.append( Field(pointer : mysql_fetch_field_direct(self.result!, i)) );
        }

        return self.lastFields!;
    };

    private func getText(buf : UnsafePointer<Int8>) -> String {
        if let utf8String = String.fromCString(buf) {
            return utf8String;
        }

        return "";
    }
}
