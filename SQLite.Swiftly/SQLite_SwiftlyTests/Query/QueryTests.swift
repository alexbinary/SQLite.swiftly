
import XCTest

@testable import SQLite_Swiftly


class QueryTests: XCTestCase {

 
    /// A query of type SELECT FROM should produce the correct SQL code.
    ///
    func test_selectQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let query = SQLite_SelectQuery(selectingFromTable: SQLite_TableDescription(name: "t", columns: []))
        
        // assert: SQL representation is correct
        
        XCTAssertEqual(query.sqlRepresentation, "SELECT * FROM t;")
    }
    
    
    /// A query of type CREATE TABLE should produce the correct SQL code.
    ///
    func test_createTableQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let column1 = SQLite_ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = SQLite_ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        
        let table = SQLite_TableDescription(name: "t", columns: [column1, column2])
        
        let query = SQLite_CreateTableQuery(creatingTable: table)
        
        // assert: SQL representation is correct
        // NB: the order of the columns is undefined
        
        assertThat(query.sqlRepresentation,
            
            matchesPattern: "CREATE TABLE t \\((.+)\\);",
            
            withUnorderedComponents: [
                
                (components: Set([column1, column2].map { $0.sqlRepresentation}), separatedBy: ", "),
            ]
        )
    }
    
    
    /// A query of type INSERT INTO should produce the correct SQL code.
    ///
    func test_insertQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let column1 = SQLite_ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = SQLite_ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        
        let table = SQLite_TableDescription(name: "t", columns: [column1, column2])
        
        let query = SQLite_InsertQuery(insertingIntoTable: table)
        
        // assert: SQL representation is correct
        // NB: the order of the columns is undefined
        
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
    
    
    /// Asserts that a string matches a pattern that contains one or more
    /// sequences of components whose order is undefined.
    ///
    /// This method first matches the provided input string against the provided
    /// regular expression pattern and asserts that there is a match.
    ///
    /// It then asserts that each part of the string that matches a capture
    /// group in the pattern matches the corresponding set of components
    /// provided in `expectedComponents`, in order, i.e. the part of the string
    /// that matches the first capture group must match the first set of
    /// components.
    ///
    /// - Parameter inputString: The string to test.
    ///
    /// - Parameter pattern: The regex pattern to evaluate the input string
    ///             against. The number of capture groups must match the number
    ///             of elements in expectedComponents.
    ///
    /// - Parameter expectedComponents: The sequences of components that must
    ///             match the capture groups in the pattern. Each sequence
    ///             contains the set of components expected to be in the capture
    ///             group and the string used to join them in the input string.
    ///
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
            
            XCTAssertTrue(String(inputString[range]).matches(componentSet), "Component set at index \(index+1) does not match components in string")
        }
    }
}


extension String {
    
    
    /// Returns whether the string matches a set of components separated by a
    /// separator string.
    ///
    /// This method splits the string using the separator specified by
    /// `componentSet.separatedBy` and compares the resulting set of components
    /// with `componentSet.components`.
    ///
    /// - Parameter componentSet: A set of strings associated with a separator.
    ///
    /// - Returns: Whether the string matches a set of components separated by a
    ///            separator string.
    ///
    func matches(_ componentSet: (components: Set<String>, separatedBy: String)) -> Bool {
        
        return Set(components(separatedBy: componentSet.separatedBy)) == componentSet.components
    }
}
