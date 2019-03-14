
import XCTest

@testable import SQLite_Swiftly


class QueryTests: XCTestCase {

 
    func test_selectQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let query = SQLite_SelectQuery(selectingFromTable: SQLite_TableDescription(name: "t", columns: []))
        
        // assert: SQL representation is correct
        
        XCTAssertEqual(query.sqlRepresentation, "SELECT * FROM t;")
    }
    
    
    func test_createTableQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let column1 = SQLite_ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = SQLite_ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        
        let table = SQLite_TableDescription(name: "t", columns: [column1, column2])
        
        let query = SQLite_CreateTableQuery(creatingTable: table)
        
        // assert: SQL representation is correct
        
        assertThat(query.sqlRepresentation,
            
            matchesPattern: "CREATE TABLE t \\((.+)\\);",
            
            withUnorderedComponents: [
                
                (components: Set([column1, column2].map { $0.sqlRepresentation}), separatedBy: ", "),
            ]
        )
    }
    
    
    func test_insertQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let column1 = SQLite_ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = SQLite_ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        
        let table = SQLite_TableDescription(name: "t", columns: [column1, column2])
        
        let query = SQLite_InsertQuery(insertingIntoTable: table)
        
        // assert: SQL representation is correct
        
        assertThat(query.sqlRepresentation,
                   
            matchesPattern: "INSERT INTO t \\((.+)\\) VALUES\\((.+)\\);",

            withUnorderedComponents: [
                
                (components: ["c1", "c2"], separatedBy: ", "),
                (components: [":c1", ":c2"], separatedBy: ", "),
            ]
        )
    }
}


extension QueryTests {
    
    
    func assertThat(
        
        _ inputString: String,
        matchesPattern pattern: String,
        withUnorderedComponents expectedComponents: [(components: Set<String>, separatedBy: String)]
        
    ) {
        
        let inputRange = NSRange(inputString.startIndex..<inputString.endIndex, in: inputString)
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let firstMatch = regex.firstMatch(in: inputString, options: [], range: inputRange)
        
        XCTAssertNotNil(firstMatch, "Input string does not match pattern")
        
        let match = firstMatch!
        
        XCTAssertEqual(match.numberOfRanges, expectedComponents.count+1, "Number of capture groups does not match number of expected components")
        
        for (index, componentSet) in expectedComponents.enumerated() {
            
            let nsrange = match.range(at: index + 1)
            let range = Range(nsrange, in: inputString)!
            
            let actualJoinedComponents = inputString[range]
            let actualSplitComponents = actualJoinedComponents.components(separatedBy: componentSet.separatedBy)
            
            XCTAssertEqual(Set(actualSplitComponents), Set(componentSet.components), "Component set at index \(index+1) does not match components in string")
        }
    }
}
