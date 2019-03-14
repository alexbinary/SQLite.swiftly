
import XCTest

@testable import SQLite_Swiftly


class DatabaseSchema: XCTestCase {

 
    func test_columnType_shouldHaveCorrectSqlRepresentation() {
        
        [
            (type: SQLite_ColumnType.char(size: 11), expectedSql: "CHAR(11)"),
            (type: SQLite_ColumnType.char(size: 64), expectedSql: "CHAR(64)"),
            (type: SQLite_ColumnType.bool, expectedSql: "BOOL"),
            
        ].forEach { (type, expectedSql) in
         
            XCTAssertEqual(type.sqlRepresentation, expectedSql, "SQL representation differ from expected.")
        }
    }
    
    
    func test_column_shouldHaveCorrectSQLRepresentation() {
        
        [
            (column: SQLite_ColumnDescription(name: "col1", type: .bool, nullable: true), expectedSql: "col1 \(SQLite_ColumnType.bool.sqlRepresentation) NULL"),
            (column: SQLite_ColumnDescription(name: "col1", type: .bool, nullable: false), expectedSql: "col1 \(SQLite_ColumnType.bool.sqlRepresentation) NOT NULL"),
        
        ].forEach { (column, expectedSql) in
            
            XCTAssertEqual(column.sqlRepresentation, expectedSql, "SQL representation differ from expected.")
        }
    }
}
