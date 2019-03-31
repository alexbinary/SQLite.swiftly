
import XCTest

@testable import SQLite_Swiftly


class ColumnDescriptionTests: XCTestCase {

 
    func test_shouldHaveCorrectSQLRepresentation() {
        
        XCTAssertEqual(SQLite_ColumnDescription(name: "col1", type: .bool, nullable: true).sqlRepresentation, "col1 \(SQLite_ColumnType.bool.sqlRepresentation) NULL")
        XCTAssertEqual(SQLite_ColumnDescription(name: "col1", type: .bool, nullable: false).sqlRepresentation, "col1 \(SQLite_ColumnType.bool.sqlRepresentation) NOT NULL")
    }
}
