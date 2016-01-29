
import Glibc;

let config = ConnectionConfig(host : "localhost", database : "test", user : "root", password : "1234567");
let conn = Connection(config : config);

do {

try conn.connect();
    let result = try conn.query("call test()");
    if let res1 = result.fetch() {
        print(res1);
    }

    result.nextRowset();
    if let res2 = result.fetch() {
        print(res2)
    }
    result.clear();
}  catch MysqlError.Error(let error, let errno) {
    print("\(errno) = \(error)");
}


do {

    let result = try conn.fetchRow("call test()");
    print(result);
}  catch MysqlError.Error(let error, let errno) {
    print("\(errno) = \(error)");
}

do {
    let result = try conn.fetchRow("call test()");
    print(result);
}  catch MysqlError.Error(let error, let errno) {
    print("\(errno) = \(error)");
}


conn.close();
