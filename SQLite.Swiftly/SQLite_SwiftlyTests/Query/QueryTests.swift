
import XCTest

@testable import SQLite_Swiftly


class QueryTests: XCTestCase {

 
    func test_selectQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let query = SQLite_SelectQuery(selectingFromTable: SQLite_TableDescription(name: "t", columns: []))
        
        // assert: SQL representation is correct
        
        XCTAssertEqual(query.sqlRepresentation, "SELECT * FROM t;")
    }
    
    
    func test_createTableQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let column1 = SQLite_ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = SQLite_ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        
        let table = SQLite_TableDescription(name: "t", columns: [column1, column2])
        
        let query = SQLite_CreateTableQuery(creatingTable: table)
        
        // assert: SQL representation is correct
        
        XCTAssertEqual(query.sqlRepresentation, "CREATE TABLE t (\(column1.sqlRepresentation), \(column2.sqlRepresentation));")
    }
    
    
    func test_insertQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let column1 = SQLite_ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = SQLite_ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        
        let table = SQLite_TableDescription(name: "t", columns: [column1, column2])
        
        let query = SQLite_InsertQuery(insertingIntoTable: table)
        
        // assert: SQL representation is correct
        
        XCTAssertEqual(query.sqlRepresentation, "INSERT INTO t (c1, c2) VALUES(:c1, :c2);")
    }
}
