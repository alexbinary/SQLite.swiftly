
# Project document


## What are we building

We are building a set of components that allow users to write code that interracts
with a SQLite database on iOS without having to deal with low level technical considerations
such as pointers and state machines.

We offer APIs that allow the programmer to express their intent rather than
manage technical details.

We offer APIs that make writing incorrect code harder by leveraging Swift's type system.

The system is simple, lightweight, fast and efficient, and is optimized for
use in My LEGO Collection.


## Whate are we not building

We are not building a full featured system.

We are not building an ultra flexible system.


## How is it different from SQLite.swift

SQLite.swift is full featured, whereas we are focused on just the features that are needed for My LEGO Collection.


## What are the features

- create a new database
- connect to an existing database
- create tables
- insert multiple rows into one table at a time efficiently
- retrieve all rows from one table at a time


## What is exposed and what is hidden

We provide a way for users to access SQLite databases. Users are expected to be
familliar with databases in general and SQLite databases in particular.

When working with SQLite databases on iOS with the vanilla APIs, a user has to
deal with a number of things, ranging from classic database concepts to API
implementation details.

Out goal is to hide from the user most of the things what are not strictly
necessary for them to accomplish their goals.

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
Exposed: yes
Reason: performance control

Opening and closing connections to a database is required to interract with it,
but is not part of the user's goals. As such, the concept of database connections
is not required to be exposed to the user.

However opening and closing connections can have serious performance impact if
done wrong, and it is difficult to do it right without beeing in the user's head.
That is why we choose to expose the concept of connections to let the user
decide how they want to manage them.

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
built a compile time, as opposed to generated at runtime. Unfortunatly, since
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

To the user, the concept of prepared statements looks like "Im about to do the
same thing multiple times, here I go, here I go, here I go, etc."

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