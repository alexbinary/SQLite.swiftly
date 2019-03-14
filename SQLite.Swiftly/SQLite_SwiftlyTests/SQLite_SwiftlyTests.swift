
import XCTest

@testable import SQLite_Swiftly


class SQLite_SwiftlyTests: XCTestCase {

    
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


extension SQLite_SwiftlyTests {
    
    
    /// Asserts that a SQLite connection returns no error.
    ///
    /// - Parameter connection: The connection to test for errors.
    ///
    func assertNoError(on connection: SQLite_Connection) {
        
        XCTAssertNil(connection.errorMessage)
    }
}


extension SQLite_SwiftlyTests {
    
    /// Opening a connection on a file that does not exist should create the
    /// file.
    ///
    func test_Connection_init_withNonExistantFile_shouldCreateDatabaseFile() {
        
        // test: connect to a new database
        
        let connection = SQLite_Connection(toDatabaseAt: testDatabaseURL)
        
        // assert: the program should create the database file and not raise any
        //         error
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: testDatabaseURL.path))
        assertNoError(on: connection)
    }
    
    
    /// Opening a connection on a file that exists should connect to the
    /// database in the file.
    ///
    func test_Connection_init_withExistantFile_shouldConnectToDatabaseInFile() {
        
        // setup: create empty database
        
        _ = SQLite_Connection(toDatabaseAt: testDatabaseURL)
        
        // test: connect to the database created above
        
        let connection = SQLite_Connection(toDatabaseAt: testDatabaseURL)
        
        // assert: no error raised on the connection
        
        assertNoError(on: connection)
    }
    
    
    /// A connection should offer a way to access the latest error message.
    ///
    func test_Connection_errorMessage_shouldBeAccessible() {
        
        // setup: open connection
        
        let connection = SQLite_Connection(toDatabaseAt: testDatabaseURL)
        
        // test: access latest error message
        
        _ = connection.errorMessage
    }
    
    
    /// Compiling a simple SQL query should not crash nor raise errors.
    ///
    func test_Connection_compile_withValidSQL_shouldNotCrash() {
        
        // setup: open connection
        
        let connection = SQLite_Connection(toDatabaseAt: testDatabaseURL)
        
        // test: compile a simple query
        // NB: `sqlite_master` is a built-in table that is guaranteed to always
        ///exist.
        
        _ = connection.compile(CustomSQLQuery(withSQL: "SELECT * FROM sqlite_master"))
        
        // assert: no error raised on the connection
        
        assertNoError(on: connection)
    }
    
    
    /// Calling `createTable()` should create the table without raising errors.
    ///
    func test_connection_createTable_shouldCreateTheTable() {
        
        // setup: open connection
        
        let connection = SQLite_Connection(toDatabaseAt: testDatabaseURL)
        
        // test: create a simple table
        
        let table = SQLite_TableDescription(name: "t", columns: [
            SQLite_ColumnDescription(name: "c", type: .char(size: 1), nullable: false)
        ])
        connection.createTable(describedBy: table)
        
        // assert: table exists and no error raised on the connection
        
        _ = connection.readAllRows(fromTable: table)
        assertNoError(on: connection)
    }
    
    
    func test_Connection_readAllRows_shouldReturnAllRowsAndAllColumns() {
        
        // setup: open connection
        
        let connection = SQLite_Connection(toDatabaseAt: testDatabaseURL)
        
        // test: create a simple table and populate with data
        
        let column1 = SQLite_ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = SQLite_ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        let table = SQLite_TableDescription(name: "t", columns: [column1, column2])
        
        connection.createTable(describedBy: table)
        
        let insertStatement = SQLite_InsertStatement(insertingIntoTable: table, connection: connection)
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
        
        assertNoError(on: connection)
    }
}


/// A SQL query built from raw SQL.
///
struct CustomSQLQuery: SQLite_Query {
    
    
    /// The SQL string that represents the query.
    ///
    let sqlRepresentation: String
   
    
    /// Creates a new query from raw SQL.
    ///
    /// - Parameter sql: The query's raw SQL string.
    ///
    init(withSQL sql: String) {
        
        sqlRepresentation = sql
    }
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
    
    
    /// Removes the file or directory at the specified URL if it exists.
    ///
    /// If the file or directory at the specified URL if exists this method
    /// does not attempt to remove it.
    ///
    func removeItemIfExists(at url: URL) throws {
    
        if fileExists(atPath: url.path) {
    
            try removeItem(at: url)
        }
    }
}
