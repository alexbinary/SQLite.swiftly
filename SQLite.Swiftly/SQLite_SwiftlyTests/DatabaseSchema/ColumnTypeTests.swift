
import XCTest

@testable import SQLite_Swiftly


class ColumnTypeTests: XCTestCase {

 
    func test_shouldHaveCorrectSqlRepresentation() {
        
        XCTAssertEqual(SQLite_ColumnType.char(size: 11).sqlRepresentation, "CHAR(11)")
        XCTAssertEqual(SQLite_ColumnType.char(size: 64).sqlRepresentation, "CHAR(64)")
        XCTAssertEqual(SQLite_ColumnType.bool.sqlRepresentation, "BOOL")
    }
}
