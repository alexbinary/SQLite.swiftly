
import XCTest

@testable import SQLite_Swiftly


class ColumnDescriptionTests: XCTestCase {

 
    func test_shouldHaveCorrectSQLRepresentation() {
        
        XCTAssertEqual(ColumnDescription(name: "col1", type: .bool, nullable: true).sqlRepresentation, "col1 \(ColumnType.bool.sqlRepresentation) NULL")
        XCTAssertEqual(ColumnDescription(name: "col1", type: .bool, nullable: false).sqlRepresentation, "col1 \(ColumnType.bool.sqlRepresentation) NOT NULL")
    }
}
