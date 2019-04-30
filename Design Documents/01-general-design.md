
# General design


## What SQLite.swiftly *is*

*SQLite.swiftly* is a set of components that allow users to interract with a 
SQLite database on iOS with ease and efficiency.

*SQLite.swiftly* is optimized for use in My LEGO Collection.

### A set of components

*SQLite.swiftly* exposes several types that form a consistent system where 
everything works together naturally and efficiently.

### That allow users to interract with a SQLite database

*SQLite.swiftly* is designed for progammers who write programs that create 
SQLite databases, store data into SQLite databases, and read data stored in 
SQLite databases.

*SQLite.swiftly* is designed specifically for SQLite databases. It does not
support other types of SQL databases.

### On iOS

*SQLite.swiftly* is designed specifically to be used on iOS.

### With ease

Ease of use is one of the main design goal of *SQLite.swiftly*, and is obtained
with the design choices described below.

First, the details of the C-style API available on iOS are hidden away, as well
as low level technical considerations such as pointers and state machines.
Programmers interract with the system using APIs that let them express their
intent rather than manage technical details.

Second, the APIs exposed respect [Swift's API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
Method calls and classes are expressive and feel natural to Swift users.

Finally, *SQLite.swiftly* relies heavily on Swift's strong type system to enable
as many compile-time checks as possible, and make writing incorrect code harder.

### With efficiency

Efficiency is the other main design goal of *SQLite.swiftly*, and is obtained
with the design choices described below.

First, *SQLite.swiftly* adds minimal overhead to common operations.

Second, *SQLite.swiftly*'s design encourages users to write efficient code.

Finally, users have full control over elements that have a significant impact on
performance and that cannot be managed transparently by *SQLite.swiftly* in an
efficient manner.

### Optimized for My LEGO Collection

*SQLite.swiftly* is designed primarily to be used in the My LEGO Collection
project. The design is optimized to provide only the features that are needed
for that  project and deliver them with the best performance.


## What SQLite.swiftly *is not*

### An abstract persistence layer

*SQLite.swiftly* is not an abstract persistence layer where usage of a SQLite
database is just an implementation detail. The target audience has specific
requirements to use SQLite databases, and they want a system that allows them to
do that.

### A full featured system

*SQLite.swiftly* does not allow users to do everything that can be done with a
SQLite database. *SQLite.swiftly* is focused on the needs of the My LEGO
Collection project and provides only the features that are needed on that
project.

### An ultra flexible system

*SQLite.swiftly* does not have extensive configuration capabilities.
*SQLite.swiftly* is focused on providing features in the most straight forward
way possible, with strong design choices that meet the needs of the My LEGO
Collection project. Configuration, if ever needed, is minimal and always based
on actual use cases.


## Feature list

### Create databases

*SQLite.swiftly* allows users to create database files that can then be used
like any other database files.

### Create tables

*SQLite.swiftly* allows users to create arbitrary tables in an existing
database. Users are free to create the table and columns they want, provided the
data types are supported. The system only supports data types that are needed in
the My LEGO Collection project.

### Insert multiple rows into a table

*SQLite.swiftly* allows users to insert one or more rows into an existing table.
Users are free to insert the data they want, but they must provide a value for
each and every column of the table.

### Retrieve all rows and all columns from a table

*SQLite.swiftly* allows users to read data from a table. The operation only
supports reading all columns and all rows. Filters, joints and functions are not
supported.


## Exposed and hidden concepts

Users of *SQLite.swiftly* are expected to be familliar with databases in
general and SQLite databases in particular.

When working with SQLite databases on iOS with the vanilla APIs, users have to
deal with a number of things, ranging from classic database concepts to API
implementation details. *SQLite.swiftly* hides away most of the things what are
not directly relevant to the user's goals.

Concepts that are part of a user's goal (e.g. the concepts of databases,
tables and columns) obviously are exposed to users, while concepts that are not
directly part of the a's goal (e.g. API implementation details) can be hidden 
from users, provided that *SQLite.swiftly* can do everything by itself while
maintaining correctness and optimal performance.

The sections below explain which concepts are exposed and which are hidden.

### Database, tables, columns, rows and values, value types

Part of a user's goal: yes
Exposed: yes

These are all concepts related to database systems. Since we provide a way for
users to access databases, these concepts are obviously exposed to users.

### Connections

Part of a user's goal: no
Exposed: no

Opening and closing connections to a database is required to interract with it,
but is not directly part of a user's goals. As such, it is not strictly required
that the concept of database connections be exposed to users.

However opening and closing connections can have serious performance impact if
done wrong. For example, when doing a lot of successive operations, it is better
to open a connection once and then reuse it for every operations, and close it
only after all operations are done.

Users who work with databases are used to managing connections, and the concept
is easily understandable by newcomers. That is why *SQLite.swiftly* exposes the
concept of connections and lets users manage them.

### Queries

Part of a user's goal: no
Exposed: no

Writing correct SQL queries is a pain that users have to go through when using
databases with traditionnal systems. Although expressing what they want to do is
part of a user's goal, writing the actual query is not. As such, it is not
strictly required that the concept of queries be exposed to users.

Although complex queries acheive the best  performance when written with care by
the user, the queries required in our use cases are basic and require no
optimization. Indeed, *SQLite.swiftly* only supports simple insertions and
selection. That is why *SQLite.swiftly* hides the concept of queries from users
and generates the queries internally.

Additionnaly, queries are plain strings that are easy to get wrong. Although
they can have dynamic parts, queries are usually written by the programmer and
built at compile time, as opposed to generated at runtime. Unfortunatly, since
they are essentially data, incorrect queries will not trigger compile time
errors, only runtime errors. This is another incentive to hide the queries from
users, as having the queries generated automatically minimizes the risk of
errors.

### Query parameters

Part of a user's goal: no
Exposed: no

Since *SQLite.swiftly* does not expose the concept of queries, neither does it
expose the concept of query parameters. Instead, users pass the data they want
the system to work on, unaware that part of it will end up filling query
parameters.

### Prepared statements

Part of a user's goal: no
Exposed: yes
Reason: performance

Prepared statements are essentially SQL queries that are compiled into an
executable form. Prepared statements are a concept that advanced databases users
may be familliar with, but usually lesser known by more occasionnal users.

As for queries, the concept of prepared statements is not required to be exposed
to users. However, in situation where the same query is run multiple times,
reusing the prepared statement can offer significant performance improvements
over compiling the same query every time.

In our use case, the most critical scenario is the one where the user inserts
large amounts of rows into a table. In that scenario, *SQLite.swiftly* could
keep a prepared statement internally and reuse it transparently for the user.
But this adds overhead, as it would need to check everytime whether a prepared
statement is available for inserts into the relevant table.

That is why although *SQLite.swiftly* does not expose the concept of queries, it
does expose the concept of prepared statements. Statements are compiled from
queries that are generated internally, and users are handed an objet that uses
the prepared statement internally. When inserting large amount of data into a
table, users first request prepared insert statements, then use the prepared
statements to insert data. Using the statements directly minimizes the overhead
and maximizes performance. A user unfamilliar with the technical concept behind
it could understand this as telling the system to *prepare* itself to do a
specific operation multiple times, getting a token that represents this
preparation, then using the token to perform the prepared operation.

### Database schema, table and column descriptions

Part of a user's goal: no
Exposed: no
Reason: single source of truth

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

Part of a user's goal: no
Exposed: no

SQLite objects have an internal state machine that requires that interractions
with the object happen in a certain way. This is an implementation details
related to the SQLite canonical APIs that has no impact on higher level concepts
that we expose to the user. That is why these are hidden from the user.

### API details

Part of a user's goal: no
Exposed: no

The details of the SQLite canonical APIs have no impact on higher level concepts
that we expose to the user. That is why these are hidden from the user.


## Quality and development experience

The system under development is subject to the highest standard of quality,
both in the final product and in the methodology.

In all aspect of the system, the code is clean, minimalist, and strives for
efficiency.

Documentation is extensive and well-crafted, and encompasses the code itself as
well as the design in general.

The system is heavily tested with a suite of automated tests that are run as 
often as possible and rigorously maintained.

Common development tasks are automated and high-quality tools are provided,
creating a robust and welcoming development environement that gives contributor
confidence and encourages the best practices available.