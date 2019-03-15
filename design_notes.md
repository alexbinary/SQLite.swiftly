
# Design notes


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