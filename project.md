
# Project document


## What are we building

We are building a set of components that allow users to interract with a SQLite
database on iOS with ease and efficiency.

The system we are building is optimized for use in My LEGO Collection.

### A set of components

The system exposes several types that form a consistent system where everything
works together naturally and efficiently.

### That allow users to interract with a SQLite database

The system is designed for progammers who write programs that create SQLite
databases, store data into SQLite databases, and read data stored in SQLite
databases.

The system is designed specifically for SQLite databases. It does not support
other types of SQL databases.

### On iOS

The system is designed specifically to be used on iOS.

### With ease

Ease of use is one of the main design goal, and is obtained with design choices
desribed below.

First, the details of the C-style API available on iOS are hidden away, as well
as low level technical considerations such as pointers and state machines.
Programmers interract with the system using APIs that let them express their
intent rather than manage technical details.

Second, the APIs exposed respect [Swift's API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
Method calls and classes are expressive and feel natural to Swift users.

Finally, the system relies heavily on Swift's strong type system to enable as
many compile-time checks as possible, and make writing incorrect code harder.

### With efficiency

Efficiency is the other main design goal, and is obtained with design choices
desribed below.

First, the system adds minimal overhead to common operations.

Second, the system's design encourages users to write efficient code.

Finally, users have full control over elements that have a significant impact on
performance and that cannot be managed transparently by the system in an
efficient manner.

### Optimized for My LEGO Collection

The system is designed primarily to be used in the My LEGO Collection project.
The design is optimized to provide only the features that are needed for that 
project and deliver them with the best performance.


## Whate are we not building

### An abstract persistence layer

We are not building an abstract persistence layer where usage of a SQLite
database is just an implementation detail.The target audience has specific
requirements to use SQLite databases, and they want a system that allows them to
do that.

### A full featured system

We are not building a system that allows users to do everything that can be done
with a SQLite database. The system is focused on the needs of the My LEGO
Collection project and provides only the features that are needed on that
project.

### An ultra flexible system

We are not building a system with extensive configuration capabilities. The
system is focused on providing features in the most straight forward way
possible, with strong design choices that meet the needs of the My LEGO
Collection project. Configuration, if ever needed, is minimal and always based
on actual use cases.


## Feature list

### Create databases

The system allows users to create database files that can then be used like any
other database files.

### Create tables

The system allows users to create arbitrary tables in an existing database.
Users are free to create the table and columns they want, provided the data
types are supported. The system only supports data types that are needed in the
My LEGO Collection project.

### Insert multiple rows into a table

The system allows users to insert one or more rows into an existing table.
Users are free to insert the data they want, but they must provide a value for
each and every column of the table.

### Retrieve all rows and all columns from a table

The system allows users to read data from a table. The operation only supports
reading all columns and all rows. Filters, joints and functions are not
supported.


## Exposed and hidden concepts

The system allows users to interract with SQLite databases. Users are expected 
to be familliar with databases in general and SQLite databases in particular.

When working with SQLite databases on iOS with the vanilla APIs, users have to
deal with a number of things, ranging from classic database concepts to API
implementation details.

The system hides away most of the things what are not directly relevant to the
user's goals.

Concepts that are part of the user's goal (e.g. the concepts of databases,
tables and columns) obviously need to be exposed, while concepts that are not
directly part of the user's goal (e.g. API implementation details) can be hidden 
from the user, provided that the system can do everything by itself while
maintaining correctness and optimal performance.

The sections below explain which concepts are exposed and which are hidden.

### Database, tables, columns, rows and values, value types

Part of the user's goal: yes
Exposed: yes

These are all concepts related to database systems. Since we provide a way for
users to access databases, these concepts are obviously exposed.

### Connections

Part of the user's goal: no
Exposed: no

Opening and closing connections to a database is required to interract with it,
but is not part of the user's goals. As such, the concept of database 
connections is not strictly required to be exposed to the user.

However opening and closing connections can have serious performance impact if
done wrong. For example, when doing a lot of successive operations, it is better
to open a connection once and then reuse it for every operations, and close it
only after all operations are done.

Users who work with databases are used to managing connections, and the concept
is easily understandable by newcomers. That is the system exposes the concept of
connections and let the user manage them.

### Queries

Part of the user's goal: no
Exposed: no

Writing correct SQL queries is a pain that users have to go through when using
databases with traditionnal systems. Although complex queries acheive the best 
performance when written with care by the user, the queries required in our use
cases are basic and require no optimization. That is why we choose to hide the
concept of queries from the user and have the system generate the queries
internally.

Additionnaly, queries are plain strings that are easy to get wrong. Although
they can have dynamic parts, queries are usually written by the programmer and
built at compile time, as opposed to generated at runtime. Unfortunatly, since
they are essentially data, incorrect queries will not trigger compile time
errors, only runtime errors. This is another incentive to hide the queries from
the user, as having the queries generated automatically minimizes the risk of
errors.

### Query parameters

Part of the user's goal: no
Exposed: no

Since the concept of queries is not exposed, neither is the concept of query
parameters. Instead, the user passes the data they want the system to work on,
unaware that some of these values will end up filling query parameters.

### Prepared statements

Part of the user's goal: no
Exposed: yes
Reason: performance control

Reusing prepared statement can offer significant performance improvements over
re-creating the same statement every time. That is why we choose to expose the
concept of prepared statements, even though the concept of queries and query 
compilation are not exposed.

### Database schema, table and column descriptions

Part of the user's goal: no
Exposed: no
Reason: making things explicit

Although not always explicilty written in code, database schemas, that is the
description of the tables and the columns in them, are an essential part when
working with databases. Indeed, users necessarily know about the tables that
exist or should exist in the database, the columns in the tables, and the data
type of each column.

Our system requires users to explicitly express the schema they need to use
before doing anything. This gives the system knowledge about the database that
users are manipulating, and helps prevent inconsistencies and errors due to an
implicit schema definition that manifests itself indirectly on multiple places.

### Internal state machines

Part of the user's goal: no
Exposed: no

SQLite objects have an internal state machine that requires that interractions
with the object happen in a certain way. This is an implementation details
related to the SQLite canonical APIs that has no impact on higher level concepts
that we expose to the user. That is why these are hidden from the user.

### API details

Part of the user's goal: no
Exposed: no

The details of the SQLite canonical APIs have no impact on higher level concepts
that we expose to the user. That is why these are hidden from the user.


## What is the expected overall quality

The system is correct and efficient, the code is clean, minimalist and documented.

Documentation is extensive and well-crafted.

The system is heavily tested.

Common development tasks are automated and high-quality tools are provided.