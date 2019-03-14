
import XCTest

@testable import SQLite_Swiftly


class SQLite_SwiftlyTests: XCTestCase {

    
    let testDatabaseURL = FileManager.default.url(forFileInCurrentDirectory: "db.sqlite")
    
    
    override func setUp() {
        
        removeTestDatabaseFileIfExists()
    }
    
    
    override func tearDown() {
        
        removeTestDatabaseFileIfExists()
    }
    
    
    func removeTestDatabaseFileIfExists() {
        
        if FileManager.default.fileExists(atPath: testDatabaseURL.path) {
            
            try! FileManager.default.removeItem(at: testDatabaseURL)
        }
    }
}


extension SQLite_SwiftlyTests {
    
    
    func test_Connection_init_withNonExistantFile_shouldCreateDatabaseFile() {
        
        // test: connect to a new database
        
        _ = SQLite_Connection(toDatabaseAt: testDatabaseURL)
        
        // assert: the program should create the database file
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: testDatabaseURL.path))
    }
    
    
    func test_Connection_init_withExistantFile_shouldConnectToDatabaseInFile() {
        
        // setup: create empty database
        
        _ = SQLite_Connection(toDatabaseAt: testDatabaseURL)
        
        // test: connect to the database created above
        
        _ = SQLite_Connection(toDatabaseAt: testDatabaseURL)
    }
    
    
    func test_Connection_errorMessage_shouldBeAccessible() {
        
        // setup: open connection
        
        let connection = SQLite_Connection(toDatabaseAt: testDatabaseURL)
        
        // test: access latest error message
        
        _ = connection.errorMessage
    }
}



extension FileManager {
    
    func url(forFileInCurrentDirectory filename: String) -> URL {
        
        return URL(fileURLWithPath: currentDirectoryPath).appendingPathComponent(filename)
    }
}
