
import Foundation
import SQLite3



/// A connection to a SQLite database.
///
/// You open a connection with the `init(toDatabaseAt:)` initializer, passing
/// the path to the SQLite database file you want to open.
///
/// Instances of this class hold a pointer to the underlying connection object.
/// It is important that you let the object be deallocated when you are done to
/// close the connection and release associated resources.
///
class SQLite_Connection {
    
    
    /// The SQLite pointer to the underlying connection object.
    ///
    /// This pointer is guaranteed to always point to a valid, open connection
    /// to the database that was passed to the initializer.
    ///
    private(set) var pointer: OpaquePointer!

    
    /// Creates a new connection to a database.
    ///
    /// This initializer opens the connection to the database. A fatal error is
    /// triggered if the connection fails.
    ///
    /// To close the connection, just let the instance be deallocated.
    ///
    /// - Parameter url: A URL to the database you want to connect to.
    ///
    init(toDatabaseAt url: URL) {
        
        guard sqlite3_open(url.path, &pointer) == SQLITE_OK else {
            
            fatalError("[SQLite_Connection] Opening database: \(url.path). SQLite error: \(errorMessage ?? "")")
        }
    }
    
    
    /// Deallocates the instance.
    ///
    /// This deinitializer closes the connection to the database and releases
    /// associated resources.
    ///
    deinit {
        
        print("[SQLite_Connection] Closing connection.")
        
        sqlite3_close(pointer)
    }
}


extension SQLite_Connection {
    
    
    /// The latest error message produced on the connection.
    ///
    /// This is `nil` if no error message has been produced yet.
    ///
    var errorMessage: String? {
        
        if let error = sqlite3_errmsg(pointer) {
            
            return String(cString: error)
            
        } else {
            
            return nil
        }
    }
}


extension SQLite_Connection {
    
    
    /// Creates a table in the database.
    ///
    /// - Parameter tableDescription: A description of the table to create.
    ///
    func createTable(describedBy tableDescription: SQLite_TableDescription) {
        
        let statement = SQLite_CreateTableStatement(creatingTable: tableDescription, connection: self)
        
        statement.run()
    }
}


extension SQLite_Connection {
    
    
    /// Reads all rows from a table.
    ///
    /// - Parameter tableDescription: A description of the table to read from.
    ///
    /// - Returns: An array of table rows. Values are read according to the type
    ///            of the corresponding column declared in the table
    ///            description.
    ///
    func readAllRows(fromTable tableDescription: SQLite_TableDescription) -> [SQLite_TableRow] {
        
        let statement = SQLite_SelectStatement(selectingFromTable: tableDescription, connection: self)
        
        let rows = statement.readAllRows()
        
        return rows
    }
}
