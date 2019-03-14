
import XCTest

@testable import SQLite_Swiftly


class DatabaseSchema: XCTestCase {

 
    func test_columnType_shouldProduceCorrectSQL() {
        
        [
            (type: SQLite_ColumnType.char(size: 11), expectedSqlRepresentation: "CHAR(11)"),
            (type: SQLite_ColumnType.char(size: 64), expectedSqlRepresentation: "CHAR(64)"),
            (type: SQLite_ColumnType.bool, expectedSqlRepresentation: "BOOL"),
            
        ].forEach { (type, expectedSQL) in
         
            XCTAssertEqual(type.sqlRepresentation, expectedSQL, "SQL representation differ from expected.")
        }
    }
}
