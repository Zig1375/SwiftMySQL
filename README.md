## Install

Now supported only Swift 2.2dev (minimal snapshot from January 25, 2016)

```sh
$ sudo apt-get install libmysqlclient-dev
```

## Introduction

This is a Swift driver for mysql.

## Here is an example on how to use it:

### Connection

```swift
import MySQL;

let config = ConnectionConfig(host : "localhost", database : "test", user : "root", password : "1234567");
let conn = Connection(config : config);

do {
    try conn.connect();

    // YOUR CODE HERE
}  catch MysqlError.Error(let error, let errno) {
    print("\(errno) : \(error)");
}
```

### Simple query

```swift
let result = try conn.query("select * from my_table;");
while let res = result.fetch() {
    print(res);
}
```

### Fast fetch row

```swift
let result = try conn.fetchRow("select * from my_table where id = 1");
print(result);
```

### Execute query without result

```swift
try conn.execute("insert into my_table(id, name) values(1, 'name')");
print(conn.insertId());
```

### Multiple statement queries
```swift
let result = try conn.query("call test()");
if let res = result.fetch() {
    print(res);
}

if (result.nextRowset()) {
    if let res = result.fetch() {
        print(res)
    }
}
```


## Results

Every row has type `[String : Value]?`.  

```swift
let res = result.fetch()!;
print( res["id"].integer );  // Returned 'Int?'
print( res["id"].float );    // Returned 'Float?'
print( res["id"].double );   // Returned 'Double?'
print( res["id"].boolean );  // Returned 'Bool?'
print( res["id"].string );   // Returned 'String?'
print( res["id"].binary );   // Returned '[UInt8]?'
```
