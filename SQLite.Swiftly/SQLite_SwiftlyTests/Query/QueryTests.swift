
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
                
                // TODO check that order is the same, i.e. "c1,c2" - ":c2,:c1" is invalid
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
        
        let substrings = inputString.extractCaptureGroups(from: pattern)
        
        XCTAssertEqual(substrings.count, expectedComponents.count, "Could not extract one or more of the expected components from the string.")

        for (index, substring) in substrings.enumerated() {
            
            XCTAssertTrue(String(substring).matches(expectedComponents[index]), "Component set at index \(index) does not match components found in the string.")
        }
    }
}


extension String {
    
    
    /// Extracts the portions of the string that match the capture groups in
    /// a regex pattern.
    ///
    /// - Parameter pattern: The regex pattern to use to extract portions of the
    ///             string.
    ///
    /// - Returns: The portions of the string that match the capture groups in
    ///            the pattern, in order.
    ///
    func extractCaptureGroups(from pattern: String) -> [Substring] {
        
        var results: [Substring] = []
        
        let inputRange = NSRange(self.startIndex..<self.endIndex, in: self)
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        if let match = regex.firstMatch(in: self, options: [], range: inputRange) {
        
            for i in 1..<match.numberOfRanges {
                
                let nsrange = match.range(at: i)
                let range = Range(nsrange, in: self)!
                
                results.append(self[range])
            }
        }
        
        return results
    }
    
    
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
        
        return Set(self.components(separatedBy: componentSet.separatedBy)) == componentSet.components
    }
}
