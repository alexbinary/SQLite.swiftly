
import XCTest

@testable import SQLite_Swiftly


class ColumnTypeTests: XCTestCase {

 
    func test_shouldHaveCorrectSqlRepresentation() {
        
        XCTAssertEqual(ColumnType.char(size: 11).sqlRepresentation, "CHAR(11)")
        XCTAssertEqual(ColumnType.char(size: 64).sqlRepresentation, "CHAR(64)")
        XCTAssertEqual(ColumnType.bool.sqlRepresentation, "BOOL")
    }
}
