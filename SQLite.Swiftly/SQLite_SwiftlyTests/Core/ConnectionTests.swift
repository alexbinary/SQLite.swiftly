
import XCTest

import SQLite3

@testable import SQLite_Swiftly


class ConnectionTests: XCTestCase {

    
    /// URL to a database used in the tests.
    ///
    /// Test runner must have write access to that location.
    ///
    let testDatabaseURL = FileManager.default.url(forFileInCurrentDirectory: "db.sqlite")
    
    
    /// Called once before each test begins.
    ///
    override func setUp() {
        
        try! removeTestDatabaseIfExists()
    }
    
    
    /// Called once after each test completes.
    ///
    override func tearDown() {
        
        try! removeTestDatabaseIfExists()
    }
    
    
    /// Makes sure no database exists at the location used in the tests.
    ///
    func removeTestDatabaseIfExists() throws {
        
        try FileManager.default.removeItemIfExists(at: testDatabaseURL)
    }
}


extension ConnectionTests {
    
    
    /// Opening a connection to a new database file should create a database
    /// file at the provided location.
    ///
    func test_init_toNewDb_shouldCreateFile() {
        
        // test: connect to a new database
        
        let connection = try? Connection(toNewDatabaseAt: testDatabaseURL)
        
        // assert:
        // - connection should succeed
        // - database file should be created
        
        XCTAssertNotNil(connection, "Connection failed.")
        XCTAssertTrue(FileManager.default.fileExists(atPath: testDatabaseURL.path), "Database file was not created.")
    }
    
    
    /// Opening a connection to a new database file should fail if a file
    /// already exists at the provided location.
    ///
    func test_init_toNewDb_shouldErrorIfFileExists() {
        
        // prepare: create an empty file
        
        FileManager.default.createFile(atPath: testDatabaseURL.path, contents: nil)
        
        // test: connect to a new database at the file's location
        
        let connection = try? Connection(toNewDatabaseAt: testDatabaseURL)
        
        // assert: connection should fail
        
        XCTAssertNil(connection, "Connection succeeded.")
    }
    
    
    /// Opening a connection to an existing database file should connect to the
    /// database in the file.
    ///
    func test_init_toExistingDb_shouldNotCrashIfFileExists() {
        
        // prepare: create empty database
        
        _ = try! Connection(toNewDatabaseAt: testDatabaseURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: testDatabaseURL.path), "Precondition failure: Database file does not exist.")
        
        // test: connect to the database created above
        
        let connection = try? Connection(toExistingDatabaseAt: testDatabaseURL)
        
        // assert: connection should succeed
        
        XCTAssertNotNil(connection, "Connection failed.")
    }
    
    
    /// Opening a connection to an existing database file should fail if the
    /// file does not exist.
    ///
    func test_init_toExistingDb_shouldErrorIfNoSuchFile() {
        
        // prepare: make sure file does not exist
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: testDatabaseURL.path), "Precondition failure: Database file exists.")
        
        // test: connect to a database that does not exist
        
        let connection = try? Connection(toExistingDatabaseAt: testDatabaseURL)
        
        // assert: connection should fail
        
       XCTAssertNil(connection, "Connection succeeded.")
    }
}


extension ConnectionTests {

    
    /// Compiling a simple SQL query should not throw.
    ///
    func test_compile_withValidSQL_shouldNotThrow() {
        
        // setup: open connection
        
        let connection = try! Connection(toNewDatabaseAt: testDatabaseURL)
        
        // test: compile a simple query
        //
        // NB: `sqlite_master` is a built-in table that is guaranteed to always
        //     exist.
        
        let statement = try? connection.compile("SELECT * FROM sqlite_master")
        
        // assert: compilation should succeed
        
        XCTAssertNotNil(statement, "Compilation failed.")
    }
    
    
    
    /// Compiling a buggy SQL query should throw.
    ///
    func test_compile_withInvalidSQL_shouldThrow() {
        
        // setup: open connection
        
        let connection = try! Connection(toNewDatabaseAt: testDatabaseURL)
        
        // test: compile a buggy query
        
        let statement = try? connection.compile("SELECT * FROM foo")
        
        // assert: compilation should fail
        
        XCTAssertNil(statement, "Compilation succeeded.")
    }
}


extension ConnectionTests {
    
    
    /// Calling `createTable()` should create the table without raising errors.
    ///
    func test_createTable_shouldCreateTheTable() {
        
        // setup: open connection
        
        let connection = try! Connection(toNewDatabaseAt: testDatabaseURL)
        
        // test: create a simple table
        
        let table = TableDescription(name: "t", columns: [
            ColumnDescription(name: "c", type: .char(size: 1), nullable: false)
        ])
        connection.createTable(describedBy: table)
        
        // assert: table should exist
        
        var connectionPointer: OpaquePointer!
        let openResult = sqlite3_open(testDatabaseURL.path, &connectionPointer)
        XCTAssertEqual(openResult, SQLITE_OK, "Verification failure: Failed to connect to database. sqlite3_open() returned \(openResult)")
        
        var statementPointer: OpaquePointer!
        let prepareResult = sqlite3_prepare_v2(connectionPointer, "SELECT * FROM sqlite_master WHERE name='\(table.name)'", -1, &statementPointer, nil)
        XCTAssertEqual(prepareResult, SQLITE_OK, "Verification failure: Failed to compile query. sqlite3_prepare_v2() returned \(prepareResult)")
        
        let stepResult = sqlite3_step(statementPointer)
        XCTAssert([SQLITE_ROW, SQLITE_DONE].contains(stepResult), "Verification failure: Query failed. sqlite3_step() returned \(stepResult)");
        
        XCTAssertEqual(stepResult, SQLITE_ROW, "Table sqlite_master does not contain a table whose name match the name of the table that should have been created.");
    }
}


extension ConnectionTests {
    
    
    func test_readAllRows_shouldReturnAllRowsAndAllColumns() {
        
        // setup: open connection
        
        let connection = try! Connection(toNewDatabaseAt: testDatabaseURL)
        
        // test: create a simple table and populate with data
        
        let column1 = ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        let table = TableDescription(name: "t", columns: [column1, column2])
        
        connection.createTable(describedBy: table)
        
        let insertStatement = InsertStatement(insertingIntoTable: table, connection: connection)
        insertStatement.insert([column1: "a", column2: "b"])
        insertStatement.insert([column1: "c", column2: "d"])
        
        // assert: table exists and no error raised on the connection
        
        let rows = connection.readAllRows(fromTable: table)
        
        XCTAssertTrue(rows.count == 2)
        
        XCTAssertTrue(rows[0].count == 2)
        XCTAssertTrue(rows[0].keys.contains(column1))
        XCTAssertTrue(rows[0].keys.contains(column2))
        XCTAssertTrue(rows[0][column1]! as! String == "a")
        XCTAssertTrue(rows[0][column2]! as! String == "b")
        
        XCTAssertTrue(rows[1].count == 2)
        XCTAssertTrue(rows[1].keys.contains(column1))
        XCTAssertTrue(rows[1].keys.contains(column2))
        XCTAssertTrue(rows[1][column1]! as! String == "c")
        XCTAssertTrue(rows[1][column2]! as! String == "d")
    }
}


/// Allows a string to be used as a query.
///
/// NB: defeats the purpose of the protocol to enforce type safe values instead
///     of opaque strings, but useful for tests.
///
extension String: Query {
    
    
    /// The SQL string that represents the query.
    ///
    public var sqlString: String { return self }
}


extension FileManager {
    
    
    /// Returns a URL to a file in the current working directory.
    ///
    /// If the current directory is `/tmp/myapp`, and you pass `f.txt` as the
    /// filename, then the result is `/tmp/myapp/f.txt`.
    ///
    /// - Parameter filename: The name of the file with extensions, e.g. "f.txt"
    ///
    /// - Returns: A URL to a file with the given name in the current working
    ///            directory.
    ///
    func url(forFileInCurrentDirectory filename: String) -> URL {
        
        return URL(fileURLWithPath: currentDirectoryPath).appendingPathComponent(filename)
    }
    
    
    /// Attempts to remove the file or directory at the specified URL only if
    /// it exists.
    ///
    /// - Parameter url: A file URL specifying the file or directory to remove.
    ///
    func removeItemIfExists(at url: URL) throws {
    
        if fileExists(atPath: url.path) {
    
            try removeItem(at: url)
        }
    }
}
