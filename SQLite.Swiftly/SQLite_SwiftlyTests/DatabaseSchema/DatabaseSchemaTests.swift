
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
    
    
    func test_table_columnNames_shouldContainNameOfAllColumns() {
        
        let table = SQLite_TableDescription(name: "t", columns: [
            SQLite_ColumnDescription(name: "col1", type: .bool, nullable: false),
            SQLite_ColumnDescription(name: "col2", type: .bool, nullable: false),
        ])
        
        XCTAssertEqual(table.columnNames, Set([ "col1", "col2" ]))
    }
    
    
    func test_table_columnsByName_shouldContainAllColumnsIndexedByTheirName() {
        
        let column1 = SQLite_ColumnDescription(name: "col1", type: .bool, nullable: false)
        let column2 = SQLite_ColumnDescription(name: "col2", type: .bool, nullable: false)
        
        let table = SQLite_TableDescription(name: "t", columns: [ column1, column2 ])
        
        XCTAssertEqual(table.columnsByName, [ "col1": column1, "col2": column2 ])
    }
    
    
    func test_table_columnWithName_shouldReturnCorrectColumnIfExists() {
        
        let column = SQLite_ColumnDescription(name: "col", type: .bool, nullable: false)
        let table = SQLite_TableDescription(name: "t", columns: [column])
        
        XCTAssertEqual(table.column(withName: "col"), column)
    }
    
    
    func test_table_columnWithName_shouldReturnNilIfNotExists() {
        
        let column = SQLite_ColumnDescription(name: "col", type: .bool, nullable: false)
        let table = SQLite_TableDescription(name: "t", columns: [column])
        
        XCTAssertEqual(table.column(withName: "foo"), nil)
    }
    
    
    func test_table_hasColumnWithName_shouldReturnTrueIfExists() {
        
        let table = SQLite_TableDescription(name: "t", columns: [
            SQLite_ColumnDescription(name: "col", type: .bool, nullable: false)
        ])
        
        XCTAssertTrue(table.hasColumn(withName: "col"))
    }
    
    
    func test_table_hasColumnWithName_shouldReturnFalseIfNotExists() {
        
        let table = SQLite_TableDescription(name: "t", columns: [
            SQLite_ColumnDescription(name: "col", type: .bool, nullable: false)
        ])
        
        XCTAssertFalse(table.hasColumn(withName: "foo"))
    }
}
