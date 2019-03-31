
import Foundation
import SQLite3



/// A connection to a SQLite database.
///
/// This class provides two initializers :
///
/// - Use the `init(toExistingDatabaseAt:)` initializer when you want to open a
///   connection to an existing database. This initializer throws an error if
///   the database file does not exist.
///
/// - Use the `init(toNewDatabaseAt:)` initializer when you want to open a
///   connection to a new database. This initializer creates a new database at
///   the location you provide and connects to it. This initializer throws an
///   error if a database file already exists at the location you provide.
///
/// Both initializers throw an error if the connection to the database fails.
///
/// The connection remains open as long as the object is not deallocated. To
/// close the connection, just let the object be deallocated.
///
/// It is important that you close the connection after use to release
/// associated resources.
///
public class Connection {
    
    
    /// The SQLite pointer to the underlying connection object.
    ///
    /// By design, this pointer should always point to a valid, open connection
    /// to the database. Code that access the pointer should make sure it
    /// remains valid at all times.
    ///
    private var pointer: OpaquePointer!

    
    /// Creates a new database and connects to it.
    ///
    /// This initializer creates a new database file at the location you provide
    /// and connects to it. The database file must not already exist, otherwise
    /// an error is thrown.
    ///
    /// The connection remains open as long as the object is not deallocated. To
    /// close the connection, just let the object be deallocated.
    ///
    /// - Parameter url: A file URL specifying the database file you want to
    ///             create and connect to.
    ///
    /// - Throws:
    ///   - If the connection fails
    ///   - If a database file already exists at the provided location
    ///   - If the database file cannot be created at the provided location
    ///
    public convenience init(toNewDatabaseAt url: URL) throws {
        
        print("[Connection] Opening connection to new database at \(url.path)")
        
        if FileManager.default.fileExists(atPath: url.path) {
            
            throw "[Connection] Cannot create database, file exists: \(url.path)"
        }
        
        try self.init(toDatabaseAt: url)
    }
    
    
    /// Creates a new connection to an existing database.
    ///
    /// This initializer opens a connection to the database file at the location
    /// you provide. The database file must exist, otherwise an error is thrown.
    ///
    /// The connection remains open as long as the object is not deallocated. To
    /// close the connection, just let the object be deallocated.
    ///
    /// - Parameter url: A file URL specifying the file that contains the
    ///             database you want to connect to.
    ///
    /// - Throws:
    ///   - If the connection fails
    ///   - If the database file does not exist
    ///   - If the database file cannot be open
    ///
    public convenience init(toExistingDatabaseAt url: URL) throws {
        
        print("[Connection] Opening connection to existing database at \(url.path)")
        
        if !FileManager.default.fileExists(atPath: url.path) {
            
            throw "[Connection] Cannot connect to database, file does not exist: \(url.path)"
        }
        
        try self.init(toDatabaseAt: url)
    }
    
    
    /// Creates a new connection to a database.
    ///
    /// This initializer opens a connection to the database at the location
    /// provided as parameter.
    ///
    /// If no database exists at the provided location, a new database is
    /// created.
    ///
    /// The connection remains open as long as the object is not deallocated.
    ///
    /// - Parameter url: A file URL specifying the database file to connect to.
    ///             If no file exists at that URL, a new file is created.
    ///
    /// - Throws:
    ///   - If the connection fails
    ///
    private init(toDatabaseAt url: URL) throws {
        
        guard sqlite3_open(url.path, &pointer) == SQLITE_OK else {
            
            throw "[Connection] sqlite3_open() failed. Opening database: \(url.path). SQLite error: \(errorMessage ?? "")"
        }
        
        print("[Connection] Connected")
    }
    
    
    /// Deallocates the instance.
    ///
    /// This deinitializer closes the connection to the database and releases
    /// associated resources.
    ///
    deinit {
        
        print("[Connection] Closing connection")
        
        sqlite3_close(pointer)
    }
}


extension Connection {
    
    
    /// The latest error message produced on the connection by the SQLite
    /// engine.
    ///
    /// Can be `nil` if the SQLite engine returns no data.
    ///
    /// - Warning: Do not assume that a `nil` value means there is no error, and
    ///            that a non-`nil` value means there is an error. The SQLite
    ///            engine can return a non-`nil` string even if there is no
    ///            error.
    ///
    var errorMessage: String? {
        
        if let raw = sqlite3_errmsg(pointer) {
            
            return String(cString: raw)
            
        } else {
    
            return nil
        }
    }
}


extension Connection {
    
    
    /// Compiles a query into a low level SQLite statement object.
    ///
    /// - Parameter query: The query to compile.
    ///
    /// - Returns: A pointer to the SQLite statement object.
    ///
    func compile(_ query: SQLite_Query) throws -> OpaquePointer {
        
        var statementPointer: OpaquePointer!
        
        guard sqlite3_prepare_v2(pointer, query.sqlRepresentation, -1, &statementPointer, nil) == SQLITE_OK else {
            
            throw "[Connection] sqlite3_prepare_v2() failed. Compiling query: \(query.sqlRepresentation). SQLite error: \(errorMessage ?? "")"
        }
        
        return statementPointer
    }
}


extension Connection {
    
    
    /// Creates a table in the database.
    ///
    /// - Parameter tableDescription: A description of the table to create.
    ///
    public func createTable(describedBy tableDescription: SQLite_TableDescription) {
        
        let statement = CreateTableStatement(creatingTable: tableDescription, connection: self)
        
        statement.run()
    }
}


extension Connection {
    
    
    /// Reads all rows from a table.
    ///
    /// - Parameter tableDescription: A description of the table to read from.
    ///
    /// - Returns: An array of table rows. Values are read according to the type
    ///            of the corresponding column declared in the table
    ///            description.
    ///
    public func readAllRows(fromTable tableDescription: SQLite_TableDescription) -> [SQLite_TableRow] {
        
        let statement = SelectStatement(selectingFromTable: tableDescription, connection: self)
        
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
