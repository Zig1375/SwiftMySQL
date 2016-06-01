## Install

Now supported only Swift 3.0 (snapshot from May 09, 2016) `swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a`

```sh
sudo apt-get install libmysqlclient-dev
```

In `Package.swift`:
```swift
dependencies: [
    // Other your packages
    .Package(url: "https://github.com/Zig1375/MySQL.git", majorVersion: 1)
]
```


## Installation (Linux, Apt-based)

1. Install the following system linux libraries:

```sh
sudo apt-get install autoconf libtool libkqueue-dev libkqueue0 libdispatch-dev libdispatch0 libhttp-parser-dev libcurl4-openssl-dev libhiredis-dev libbsd-dev
```

2. Install libdispatch:
```sh
git clone -b experimental/foundation https://github.com/apple/swift-corelibs-libdispatch.git
cd swift-corelibs-libdispatch
git submodule init
git submodule update
sh ./autogen.sh
./configure --with-swift-toolchain=<path-to-swift>/usr --prefix=<path-to-swift>/usr
make && sudo make install
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
} catch {
    print("Unknown error")
}
```


### Pooling connections
```swift
import MySQL;

let db_pool = Pool(config : ConnectionConfig(host : "localhost", database : "test", user : "root", password : "1234567"), connectionLimit : 100);

if let conn = db_pool.getConnection() {
    // YOUR CODE HERE

    db_pool.release(conn);
}
```


### Simple query

```swift
let result = try conn.query(sql : "select * from my_table;");
while let res = result.fetch() {
    print(res);
}
```

### Fast fetch row

```swift
let result = try conn.fetchRow(sql : "select * from my_table where id = 1");  // Returned 'Row?'
print(result);
```

### Fast fetch all row

```swift
let result = try conn.fetchAll(sql : "select * from my_table");               // Returned '[Row]'
print(result);
```

### Execute query without result

```swift
try conn.execute(sql : "insert into my_table(id, name) values(1, 'name')");
print(conn.insertId());
```

### Multiple statement queries
```swift
let result = try conn.query(sql : "call test()");
if let res = result.fetch() {
    print(res);
}

if (result.nextRowset()) {
    if let res = result.fetch() {
        print(res)
    }
}
```

### Preparing Queries
You can use `Parameters` to prepare a query with multiple insertion points, utilizing the proper escaping for ids and values. A simple example of this follows:

```swift
let p = Parameters(sql : "SELECT * FROM test.new_table where col1 = {0} and col2 = {1};", values : ["foo", "bar"]);
let result = try conn.query(p : p);
while let res = result.fetch() {
    print(res);
}
```

Or other variant:

```swift
let p = Parameters(sql : "SELECT * FROM test.new_table where col1 = {col1} and col2 = {col2};");
p.bind("col1", value : 123);
p.bind("col2", value : "foo");

let result = try conn.query(p : p);
while let res = result.fetch() {
    print(res);
}
```

Following this you then have a valid, escaped query that you can then send to the database safely. This is useful if you are looking to prepare the query before actually sending it to the database.


## Results

Every row has type `Row`.
`Row` can return value in any types.

### Sample:
```swift
let res = result.fetch()!;
print( res["id"].integer );  // Returned 'Int?'
print( res["id"].float );    // Returned 'Float?'
print( res["id"].double );   // Returned 'Double?'
print( res["id"].boolean );  // Returned 'Bool?'
print( res["id"].string );   // Returned 'String?'
print( res["id"].binary );   // Returned '[UInt8]?'
```
