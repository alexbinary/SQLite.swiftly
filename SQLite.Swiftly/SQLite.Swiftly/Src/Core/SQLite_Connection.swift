
import Foundation
import SQLite3



/// A connection to a SQLite database.
///
/// You open a connection to an existing database with the
/// `init(toExistingDatabaseAt:)` initializer, passing the path to the SQLite
/// database file you want to open.
///
/// You open a connection to a new database with the `init(toNewDatabaseAt:)`
/// initializer, passing the path to the SQLite database file you want to
/// create. This initializer creates a new database at the location you provide
/// and connects to it.
///
/// The connection remains open as long as the object is not deallocated.
/// Therefore it is important that you let the object be deallocated when it is
/// not needed anymore to close the connection and release associated resources.
///
public class SQLite_Connection {
    
    
    /// The SQLite pointer to the underlying connection object.
    ///
    /// This pointer is expected to always point to a valid, open connection
    /// to the database. The property therefore needs to remain private to
    /// prevent someone on the outside of this class to change the pointer or
    /// the object it points to. The value being a pointer to an object,
    /// exposing it in read-only mode is not enough, as accessing the pointer's
    /// value allows a third party to make changes to the object it points to.
    ///
    private var pointer: OpaquePointer!

    
    /// Creates a new database and connects to it.
    ///
    /// This initializer creates a new database file at the location provided as
    /// parameter and opens a connection to the database.
    ///
    /// An error is thrown if the connection fails, if the file cannot be
    /// created, or if a database already exist in that location.
    ///
    /// The connection remains open as long as the object is not deallocated.
    ///
    /// - Parameter url: A URL that indicates the location of the database you
    ///             want to create.
    ///
    public convenience init(toNewDatabaseAt url: URL) throws {
        
        print("[SQLite_Connection] Opening connection to new database at \(url.path)")
        
        if FileManager.default.fileExists(atPath: url.path) {
            
            throw "[SQLite_Connection] Cannot create database, file exists: \(url.path)"
        }
        
        try self.init(toDatabaseAt: url)
    }
    
    
    /// Creates a new connection to an existing database.
    ///
    /// This initializer opens the connection to the database at the location
    /// provided as parameter.
    ///
    /// An error is thrown if the connection fails or if the file does not
    /// exist.
    ///
    /// The connection remains open as long as the object is not deallocated.
    ///
    /// - Parameter url: A URL to a file that contains the database you want to
    ///             connect to.
    ///
    public convenience init(toExistingDatabaseAt url: URL) throws {
        
        print("[SQLite_Connection] Opening connection to existing database at \(url.path)")
        
        if !FileManager.default.fileExists(atPath: url.path) {
            
            throw "[SQLite_Connection] Cannot connect to database, file does not exist: \(url.path)"
        }
        
        try self.init(toDatabaseAt: url)
    }
    
    
    /// Creates a new connection to a database.
    ///
    /// This initializer opens the connection to the database at the location
    /// provided as parameter.
    ///
    /// If no database exists at the provided location, a new database is
    /// created.
    ///
    /// An error is thrown if the connection fails.
    ///
    /// The connection remains open as long as the object is not deallocated.
    ///
    /// - Parameter url: A URL to the database file to connect to.
    ///
    private init(toDatabaseAt url: URL) throws {
        
        guard sqlite3_open(url.path, &pointer) == SQLITE_OK else {
            
            throw "[SQLite_Connection] sqlite3_open() failed. SQLite error: \(errorMessage ?? "")"
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
    
    
    /// Compiles a query into a low level SQLite statement object.
    ///
    /// - Parameter query: The SQL query to compile.
    ///
    /// - Returns: A pointer to the SQLite statement object.
    ///
    func compile(_ query: SQLite_Query) throws -> OpaquePointer {
        
        var statementPointer: OpaquePointer!
        
        guard sqlite3_prepare_v2(pointer, query.sqlRepresentation, -1, &statementPointer, nil) == SQLITE_OK else {
            
            throw "[SQLite_Connection] Compiling query: \(query.sqlRepresentation). SQLite error: \(errorMessage ?? "")"
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
