
import XCTest

@testable import SQLite_Swiftly


class DatabaseSchema: XCTestCase {

 
    func test_column_shouldHaveCorrectSQLRepresentation() {
        
        [
            (column: SQLite_ColumnDescription(name: "col1", type: .bool, nullable: true), expectedSql: "col1 \(SQLite_ColumnType.bool.sqlRepresentation) NULL"),
            (column: SQLite_ColumnDescription(name: "col1", type: .bool, nullable: false), expectedSql: "col1 \(SQLite_ColumnType.bool.sqlRepresentation) NOT NULL"),
        
        ].forEach { (column, expectedSql) in
            
            XCTAssertEqual(column.sqlRepresentation, expectedSql, "SQL representation differ from expected.")
        }
    }
}
