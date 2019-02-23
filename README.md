#  SQLite.swiftly

*SQLite.swiftly* is a simple Swift wrapper on  top of the C-style SQLite APIs available on Apple platforms.

*SQLite.swiftly* is being developped as part of the [My LEGO Collection](https://github.com/alexbinary/My-LEGO-Collection)  project.
It was originally part of the source code of the project, but has been moved into its own repository so it can have its own life,
and why not inspire someone.

*SQLite.swiftly* provides type safe APIs to work with SQLite database, with as much compile time checks as possible,
so you can avoid many common mistakes even before running your app.

Besides the fact that the SQLite C-style APIs require the use of low level and not very swifty types such as `UnsafePointer` instead of `String`,
connections and statement are both manipulated through pointers of the same type `OpaquePointer`, which makes it easy to make mistakes
and pass one object when you intended the other one.

By nature, a pointer can point to an uninitialized or disposed object, and there is no way to know
if it points to a valid object at compile time. Keeping track of what the pointers point to is on the programmer.

On top of that, objects have an internal state machine, which the programmer must keep track of
in order to make the appropriate calls at the appropriate time. Again, it is easy to make mistakes,
and the compiler cannot help at all. All work is on the programmer.

*SQLite.swiftly* solves all these problems so you can focus on building your app instead of
managing pointers and state machines.

The design of *SQLite.swiftly* makes it very hard to write wrong code.

Let's see how it works:

```swift
// vanilla C-style API

var connectionPointer: OpaquePointer!
sqlite3_open("path/to/db.sqlite", &connectionPointer)

var statementPointer: OpaquePointer!
sqlite3_prepare_v2(connectionPointer, "INSERT INTO table(c1, c2) VALUES(1,2"), -1, &statementPointer, nil)

// what if the connection failed ? we can use a if condition, but nothing is preventing us to use the connection pointer event if the connection failed.
// what if we made a mistake in the SQL query ?
// what's that -1 doing ?
// what if we mistakenly swap the connectionPointer and statementPointer ?

sqlite3_finalize(statementPointer)  // now statementPointer cannot be used anymore, but who can tell ? we need to keep track of whether sqlite3_finalize() was called on that pointer.  

sqlite3_close(connectionPointer)    // same thing with connectionPointer


// now with SQLite.swiftly

var connection: SQLite_Connection! = SQLite_Connection(toDatabaseAt: "path/to/db.sqlite")

// connection is guaranteed to be a valid connection, if the connection failed a fatal error is raised.

// lets first describe our table:

let c1 = SQLite_ColumnDescription(
    name: "c1",
    type: .char(size: 255),
    nullable: false
)

let c2 = SQLite_ColumnDescription(
    name: "c2",
    type: .char(size: 255),
    nullable: true
) 

let table = SQLite_TableDescription(name: "table", columns: [c1, c2])

// now lets create a statement that inserts data in the table:

let statement = SQLite_InsertStatement(insertingIntoTable: table, connection: connection)

// again, statement is guaranteed to be a valid statement
// since we did not write the SQL query ourself, we cannot make mistakes in it!

// now lets insert data :

statement.insert([
    c1: "value1",
    c2: nil,
])

// now lets close the connection:

connection = nil

// the connection is closed when the connection object is deallocated
// thus, as long as you have a non-nil object, the connection is guaranteed to be open
// using optionals as we did here forces you to think about the possibility of the connection being invalid *as you write the code*
```

## Design considerations

There is no proper error handling yet. Any error triggers a fatal error.

Proper error handling is planned. 


## Features

Supported SQLite data types :

- [x] char
- [x] bool

Supported operations :

- [x] create tables
- [x] insert into tables (all columns only)
- [x] select from tables (all columns only)(no chunked reading, not suited for very large data sets)


## Demo / Development project

TODO
