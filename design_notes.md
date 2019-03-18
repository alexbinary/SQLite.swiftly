
# Design notes


## SQLite.swiftly is designed for the needs of the My LEGO Collection project

In My LEGO Collection we need to:

- create nex SQLite databases
- create tables from a static schema
- insert large data sets into the tables efficiently
- open an existing SQLite database
- read all data from a table

As a result *SQLite.swiftly* implements only these features, and does so with
the goal of achieving the best performance.

Many features you would expect from a generic SQLite client are not implemented
in *SQLite.swiftly*.


## Connection and Statement encapsulate low level objects

Connection and Statement are the two main objects in *SQLite.swiftly*.

Each of them is a wrapper around the corresponding low level SQLite object, and
hold a reference to a pointer that points to that object.

Connection and Statement fully control the lifecycle and state machine of the
low level object.

The pointer is fully private and cannot be accessed from outside the instance
of Connection or Statement that contain it, and Connection and Statement are not
designed to handle a change in the pointer or the object that happen outside of
their control.

Connection and Statement create the low level object themselves in their
initializer. This guarantees that nobody has ever access to it and thus protects
from changes happening outside of their control.

From the user point of view, Connection and Statement are stateless: all public
methods can be called at any time and in any order.


## Statements are linked to a Connection

A Statement holds a reference to the connection that was used to compile it.
The connection that was used to compile the statement is the connection on which
the statement executes when it is run.

Internally, the connection is used to access the error message if an error
occurs when the statement runs.

Accessing the connection from outside the Statement instance would be ok as 
there is nothing that a user can do to the connection that would make the 
statement invalid.

The reference to the connection is kept private until we see a relevant scenario
where one would need to access it.


## Low level statements objects are created by instances of Connection

Compiling a statement requires access to the low level connection object. As
that object is private to the Connection object, only the Connection object can
compile a statement.

The Connection class provides an internal method that produces a low level
statement object from a Query object.

Statement objects call that method in their initializer to create the low level 
object they encapsulate.

The Connection class cannot directly produce an instance of Statement because it
would have to inject the low level object into an already initialized Statement
instance, which is impossible by design (see above).


## Statement has one general purpose public method

Statement has only one public method besides the initializer. This method
triggers the execution of the statement and returns the rows that the statment
returns.

The method takes a list of parameters that get bound to the statement.
Parameters are verified against the actual query to make sure that all
parameters are given a value.

The method takes a table model that is used to read the raw data in the
appropriate format and present the output data. The model is verified against
the actual data to make sure that they match.

The underlying state machine is reset on each execution so that the method can
be called multiple times with different parameters.


## Connection offers convenience methods

Connection offers conveniance methods to execute simple queries on the
connection without having to create a Statement. The method creates the
Statement for you and executes it immediately.

The followong convenience methods exist:
- create a table from a table model
- read all rows from a table


## Inserts use explicit prepared statement

Insert statements insert one row at a time. Although there are ways to insert
multiple rows in one single `INSERT INTO` query, inserting only one row allows
a much simpler design. Using prepared statements mitigates the possible
performance loss.

To insert data into a table, the user must explicitly request a prepared
statement, then use it to insert data. 

This helps achieve good performances when inserting large amount of data as it
encourages the use of one prepared statement to insert many rows.

Having a convenience method on the connection that compiles a statement and
inserts a single row would make it too easy for the user to inadvertantly
compile a new statement for each row they insert.

`SELECT` and `CREATE TABLE` statements are not usually run multiple times with
varying data, so compiling a new statement each time is not an issue.


## Only insert statement are exposed for public usage

Although internally various subclasses of Statement are used, almost everything 
can be achieved using convenience methods on the Connection class.

Thus, Statement and most of its subclasses do not need to be exposed for public
use.

Inserting data is the only operation that requires explicit use of Statement
object, and thus only the corresponding subclass of Statement needs to be
exposed for public use.


## Connection has two intializers that expect the database to exist or not exist

The native SQLite function create a new database when you try to connect to a
database that does not exist. This is convenient but can lead to confusion.

When you request a connection to a database, we ask you to express whether you
expect the database to exist or not. If you expect the database to exist and it
does not, then an error is raised. Same if you expect the database to not exist
and it does.

This helps prevent errors as most of the time you want to either create a new
database or connect to an existing database.

If you want to create a new database then you want to be alerted if a database
already exists in the location you specified.

If you want to connect to an existing database then you do want to be alerted
if the database does not exist.


## Things are exposed for public use only if they need to be

Classes, structs, enums, protocols, methods and properties are exposed for
public use only if there is at least one approved scenario where a user would
need to use them.

By default, things are kept internal or private.


## SQL queries never transit as strings

Whenever a SQL query is expected, use an instance of a type that conforms to the
`SQLQuery` protocol. Passing SQL queries as strings should be avoided at all
costs as this provides no guarantee that the string contains a valid SQL query.


## Error handling uses conventional swift strategy

Methods that can fail can throw enum values that conform to the swift `Error`
protocol.

It is up to the user to handle the error in any way they want.

Using `fatalError()` as was initially the case, although simple and convenient,
is not testable. Throwable functions are testable.


## Error handling is minimal

Until *SQLite.swiftly* becomes more stable, error handling will recieve only as
much attention as is absolutely required.

For now, error handling is mostly useful to the programmer and should be
designed to help identify design errors or external constraints that need to be
addressed in the design.

Proper error handling intented for the user is planned once the project becomes
stable enough.

Only the main code path is considered. Alternative code paths are not considered
at all and any detectable divergence from the main path triggers an error.

Only one, generic type of error is used. The error carries a custom message
designed to help the programmer identify what went wrong.


## Connection provides internal access to the latest error message

When errors occur on a connection, the latest error message is stores and can
be access with a simple function. If no error has occured yet, the error message
says "not an error".

Connection offers a high level way to access the latest error message, with the
added benefit of a clearly identified "no error" case. When the error is "not an
error", Connection returns `nil` instead.

The error message is not intended to be used publicly by client code, as it is
part of the implementation details. It is however usefull to other classes that
are related to a connection, namely statements. Statements log the connection's
error message when they detect an error during their execution.