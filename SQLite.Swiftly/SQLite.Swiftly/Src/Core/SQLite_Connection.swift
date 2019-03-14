
import Foundation
import SQLite3



/// A connection to a SQLite database.
///
/// You open a connection with the `init(toDatabaseAt:)` initializer, passing
/// the path to the SQLite database file you want to open. If the file does not
/// exist it is created.
///
/// After initialization, instances of this class always represent a valid
/// database connection. To close connection you must let the object be
/// deallocated.
///
/// It is important that you let the object be deallocated when it is not needed
/// anymore to close the connection and release associated resources.
///
public class SQLite_Connection {
    
    
    /// The SQLite pointer to the underlying connection object.
    ///
    /// This should always be a pointer that points to a valid, open connection
    /// to the database that was passed to the initializer.
    ///
    private var pointer: OpaquePointer!

    
    /// Creates a new connection to a database.
    ///
    /// This initializer opens the connection to the database. A fatal error is
    /// triggered if the connection fails.
    ///
    /// To close the connection, you must let the object be deallocated.
    ///
    /// - Parameter url: A URL to a file that contains the database you want to
    ///             connect to.
    ///
    public init(toDatabaseAt url: URL) {
        
        print("[SQLite_Connection] Opening connection to file \(url.path)")
        
        if FileManager.default.fileExists(atPath: url.path) {
            
            print("[SQLite_Connection] File exists, connecting to existing database...")
        } else {
            print("[SQLite_Connection] File does not exist, creating new database...")
        }
        
        guard sqlite3_open(url.path, &pointer) == SQLITE_OK else {
            
            fatalError("[SQLite_Connection] Opening database: \(url.path). SQLite error: \(errorMessage ?? "")")
        }
        
        print("[SQLite_Connection] Connected")
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
        
        if let rawErrorString = sqlite3_errmsg(pointer) {
            
            let errorString = String(cString: rawErrorString)
            
            if errorString != SQLiteConstants.ERROR_NO_ERROR {
                
                return errorString
            }
        }
        
        return nil
    }
}


extension SQLite_Connection {
    
    
    /// Compiles a query into a statement and returns a raw SQLite pointer to
    /// the statement.
    ///
    /// - Parameter query: The SQL query to compile.
    ///
    /// - Returns: A pointer to the SQLite statement object.
    ///
    func compile(_ query: SQLite_Query) -> OpaquePointer {
        
        var statementPointer: OpaquePointer!
        
        guard sqlite3_prepare_v2(pointer, query.sqlRepresentation, -1, &statementPointer, nil) == SQLITE_OK else {
            
            fatalError("[SQLite_Connection] Compiling query: \(query.sqlRepresentation). SQLite error: \(errorMessage ?? "")")
        }
        
        return statementPointer
    }
}


extension SQLite_Connection {
    
    
    /// Creates a table in the database.
    ///
    /// - Parameter tableDescription: A description of the table to create.
    ///
    public func createTable(describedBy tableDescription: SQLite_TableDescription) {
        
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
    public func readAllRows(fromTable tableDescription: SQLite_TableDescription) -> [SQLite_TableRow] {
        
        let statement = SQLite_SelectStatement(selectingFromTable: tableDescription, connection: self)
        
        let rows = statement.readAllRows()
        
        return rows
    }
}


/// Collection of constant values.
///
enum SQLiteConstants {
    
    /// Error string returned by the SQLite engine when there is no error.
    ///
    static let ERROR_NO_ERROR = "not an error"
}
