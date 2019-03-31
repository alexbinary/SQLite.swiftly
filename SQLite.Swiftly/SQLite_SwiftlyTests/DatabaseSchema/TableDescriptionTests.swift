
import XCTest

@testable import SQLite_Swiftly


class TableDescriptionTests: XCTestCase {

 
    func test_columnWithName_shouldReturnCorrectColumnIfExists() {
        
        let column = ColumnDescription(name: "col", type: .bool, nullable: false)
        let table = SQLite_TableDescription(name: "t", columns: [column])
        
        XCTAssertEqual(table.column(withName: "col"), column)
    }
    
    
    func test_columnWithName_shouldReturnNilIfNotExists() {
        
        let table = SQLite_TableDescription(name: "t", columns: [
            ColumnDescription(name: "col", type: .bool, nullable: false)
        ])
        
        XCTAssertNil(table.column(withName: "foo"))
    }
    
    
    func test_hasColumnWithName_shouldReturnTrueIfExists() {
        
        let table = SQLite_TableDescription(name: "t", columns: [
            ColumnDescription(name: "col", type: .bool, nullable: false)
        ])
        
        XCTAssertTrue(table.hasColumn(withName: "col"))
    }
    
    
    func test_hasColumnWithName_shouldReturnFalseIfNotExists() {
        
        let table = SQLite_TableDescription(name: "t", columns: [
            ColumnDescription(name: "col", type: .bool, nullable: false)
        ])
        
        XCTAssertFalse(table.hasColumn(withName: "foo"))
    }
}
