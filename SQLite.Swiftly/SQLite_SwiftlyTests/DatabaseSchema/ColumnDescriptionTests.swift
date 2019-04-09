
import XCTest

@testable import SQLite_Swiftly


class ColumnDescriptionTests: XCTestCase {

 
    func test_shouldHaveCorrectSQLRepresentation() {
        
        XCTAssertEqual(
            ColumnDescription(name: "col1", type: .bool, nullable: true).sqlRepresentation,
            "col1 BOOL NULL"
        )
        XCTAssertEqual(
            ColumnDescription(name: "col1", type: .char(size: 11), nullable: false).sqlRepresentation,
            "col1 CHAR(11) NOT NULL"
        )
    }
}
