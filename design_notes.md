# Design notes

## Connection

A Connection holds a reference to the low level SQLite pointer.

## Statement

A Statement holds a reference to the low level SQLite pointer.

The low level pointer is produced by the connection object.

## Interractions between Connection and Statement

A Statement holds a reference to the connection that was used to compile it.
This connection is also the connection on which the statement executes when it is run.
The connection is used to access the error message if an error occurs.

Connection provides a public (internal) method to produce a low level statement pointer, because doing so requires access to the connection pointer,
and we do not want to expose the connection pointer outside of the Connection object to avoid any risk of corrupting
a pointer that is used by a connection object, as it is not designed to handle a pointer that changes outside of its control.

## Statement public interface design

Statement has only one public method besides the initializer.

This method allows a complete execution fo the statement and includes data binding
and data reading. This method is very generic and is the base for all, more specific
convenience methods exposed by the subclasses.

This method can be called multiple times with different parameters.
The underlying state machine is reset on each execution.

This method takes a list of parameters that are bound to the statement.
Parameters are verified against the actual query to make sure that all parameter are given a value.

This method takes a table model that is used to read the raw data in the appropriate format and present the output data.
The model is verified against the actual data to make sure that they match.

Private methods take care of dynamic parameter verification, parameter binding, statement execution, table model validation and data presentation.