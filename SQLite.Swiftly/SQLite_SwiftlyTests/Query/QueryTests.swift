
import XCTest

@testable import SQLite_Swiftly


class QueryTests: XCTestCase {

 
    /// A query of type SELECT FROM should produce the correct SQL code.
    ///
    func test_selectQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let query = SQLite_SelectQuery(selectingFromTable: TableDescription(name: "t", columns: []))
        
        // assert: SQL representation is correct
        
        XCTAssertEqual(query.sqlRepresentation, "SELECT * FROM t;")
    }
    
    
    /// A query of type CREATE TABLE should produce the correct SQL code.
    ///
    func test_createTableQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let column1 = ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        
        let table = TableDescription(name: "t", columns: [column1, column2])
        
        let query = SQLite_CreateTableQuery(creatingTable: table)
        
        // assert: SQL representation is correct
        // NB: the order of the columns is undefined
        
        assertThat(query.sqlRepresentation,
            
            matchesPattern: "CREATE TABLE t \\((.+)\\);",
            
            withUnorderedComponents: [
                
                (components: [column1, column2].map { $0.sqlRepresentation}, separatedBy: ", "),
            ]
        )
    }
    
    
    /// A query of type INSERT INTO should produce the correct SQL code.
    ///
    func test_insertQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let column1 = ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        
        let table = TableDescription(name: "t", columns: [column1, column2])
        
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
    /// This method attempts to extract substrings from the input string that
    /// match the capture groups in the provided regex pattern.
    ///
    /// It then asserts that each substring matches the corresponding set of
    /// components provided in `expectedComponents`, in order, i.e. the first
    /// substring must match the first set of components.
    ///
    /// A substring matches a set of components if the set of parts obtained by
    /// splitting it with the specified separator matches exactly the specified
    /// set of components.
    ///
    /// Additionnally, and while the order in which the components appear in
    /// each substring is not relevant, the order must be the same in all the
    /// substrings.
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
    ///             group and the string used to join them. The number of
    ///             elements in this array must match the number of capture
    ///             groups in the pattern.
    ///
    func assertThat(
        
        _ inputString: String,
        matchesPattern pattern: String,
        withUnorderedComponents expectedComponents: [(components: [String], separatedBy: String)]
        
    ) {
        
        // 1 - extract substrings
        
        let substrings = inputString.extractCaptureGroups(from: pattern)
        
        XCTAssertEqual(substrings.count, expectedComponents.count, "Could not extract one or more of the expected components from the string.")

        // 2 - prepare components lists
        
        let nakedComponents = zip(substrings, expectedComponents).map { (substring, expectedComponentSet) in
            return (
                actual: substring.components(separatedBy: expectedComponentSet.separatedBy),
                expected: expectedComponentSet.components
            )
        }
        
        // 3 - check that actual components match expected components in all substrings
        
        nakedComponents.forEach {
            
            XCTAssertEqual(Set($0.actual), Set($0.expected), "Components found in the string do not match expected components.")
        }
        
        // 4 - check that components always appear in the same order in all substrings
        
        let orders = nakedComponents.map { (actual, expected) in
            
            return actual.map { expected.firstIndex(of: $0)! }
        }
        
        XCTAssertEqual(Set(orders).count, 1, "Order of appearance of components differ in two or more sequences.")
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
}
