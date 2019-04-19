
import XCTest

@testable import SQLite_Swiftly


class QueryTests: XCTestCase {

 
    /// A query of type SELECT FROM should produce the correct SQL code.
    ///
    func test_selectQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let query = SelectQuery(selectingFromTable: TableDescription(name: "t", columns: []))
        
        // assert: SQL representation should be correct
        
        XCTAssertEqual(query.sqlString, "SELECT * FROM t;")
    }
    
    
    /// A query of type CREATE TABLE should produce the correct SQL code.
    ///
    func test_createTableQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let column1 = ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        let table = TableDescription(name: "t", columns: [column1, column2])
        
        let query = CreateTableQuery(creatingTable: table)
        
        // assert: SQL representation is correct
        //
        // NB: by design, we cannot expect the query to list the columns in any specific order
        
        assertThat(query.sqlString,
            matchesPattern: "^CREATE TABLE t \\((.+)\\);$",
            withUnorderedComponents: [
                (components: [column1, column2].map { $0.sqlRepresentation}, separator: ", "),
            ]
        )
    }
    
    
    /// A query of type INSERT INTO should produce a named parameter for each column.
    ///
    func test_insertQuery_shouldProduceANamedParameterForEachColumn() {
        
        // setup: create a simple query
        
        let column1 = ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        let table = TableDescription(name: "t", columns: [column1, column2])
        
        let query = InsertQuery(insertingIntoTable: table)
        
        // assert: each column should have an associated named parameter
        //
        // NB: by design, we cannot expect the parameter to have a specific name
        
        [column1, column2].forEach { column in
            
            XCTAssertNotNil(query.parameters[column], "Missing parameter for column \(column.name)")
            XCTAssertTrue(query.parameters[column]!.name.starts(with: ":"), "Parameter for column \(column.name) is not a valid named parameter.")
        }
    }
    
    
    /// A query of type INSERT INTO should produce the correct SQL code.
    ///
    func test_insertQuery_shouldProduceCorrectSQL() {
        
        // setup: create a simple query
        
        let column1 = ColumnDescription(name: "c1", type: .char(size: 1), nullable: false)
        let column2 = ColumnDescription(name: "c2", type: .char(size: 1), nullable: false)
        let table = TableDescription(name: "t", columns: [column1, column2])
        
        let query = InsertQuery(insertingIntoTable: table)
        
        // assert: SQL representation is correct
        //
        // NB: by design, we cannot expect the query to list the columns in any specific order
        
        assertThat(query.sqlString,
            matchesPattern: "^INSERT INTO t \\((.+)\\) VALUES\\((.+)\\);$",
            withUnorderedComponents: [
                (components: [column1, column2].map { $0.name }, separator: ", "),
                (components: [column1, column2].map { query.parameters[$0]!.name }, separator: ", "),
            ]
        )
    }
}


extension QueryTests {
    
    
    /// Asserts that a string matches a regex pattern and that the substrings
    /// defined by the capturing groups match sequences of components whose
    /// order is undefined.
    ///
    /// This method first checks if the input string matches the regex pattern
    /// at all.
    ///
    /// If the input string matches the pattern, it then extracts substrings
    /// from the input string that match the capturing groups in the regex
    /// pattern.
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
    /// Example:
    ///
    ///     If the pattern is
    ///
    ///         "toto (.+) titi (.+)"
    ///
    ///      and the expected components are
    ///
    ///         (components: ["bar", "foo"], separator: "-")
    ///         (components: ["baz", "bar"], separator: "-")
    ///
    ///     then the following input strings give the following results:
    ///
    ///         "toto (bar-foo) titi (baz-bar)" -> match
    ///         "toto (foo-bar) titi (bar-baz)" -> match
    ///
    ///         "toto (foo-bar) titi (baz-bar)" -> no match
    ///         "toto (bar-foo) tata (baz-bar)" -> no match
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
        withUnorderedComponents expectedComponents: [(components: [String], separator: String)]
        
    ) {
        
        // 0 - Check that the input string matches the pattern at all.
        //
        //      e.g. if the the pattern is
        //
        //              "toto (.+)"
        //
        //      and the input string is
        //
        //              "toto"
        //
        //      then the input string does not match the pattern
        
        XCTAssertTrue(inputString.matches(pattern), "The input string does not match the pattern.")
        
        // 1 - Extract substrings.
        //
        //      e.g. if the pattern is
        //
        //              "toto (.+) titi (.+)"
        //
        //      and the input string is
        //
        //              "toto foo titi bar"
        //
        //      then the substrings are
        //
        //              ["foo", "bar"]
        
        let substrings = inputString.substringsForCapturingGroups(definedBy: pattern)
        
        XCTAssertEqual(substrings.count, expectedComponents.count, "The input string does not contains the expected number of components.")

        // 2 - Prepare components lists.
        //
        //  For each substring, we split it with the separator specified by the corresponding reference components set
        //  and we associate the components from the reference components set.
        //
        //      e.g. if the substrings are
        //
        //              ["foo,bar", "bar,baz"]
        //
        //      and the reference components sets are
        //
        //              (components: ["bar", "foo"], separator: ",")
        //          and (components: ["bar", "baz"], separator: ",")
        //
        //      then we have
        //
        //              (actual: ["foo", "bar"], expected ["bar", "foo"])
        //          and (actual: ["bar", "baz"], expected ["bar", "baz"])
        
        let nakedComponents = zip(substrings, expectedComponents).map { (substring, expectedComponentSet) in
            return (
                actual: substring.components(separatedBy: expectedComponentSet.separator),
                expected: expectedComponentSet.components
            )
        }
        
        // 3 - Check that actual components match expected components in all substrings.
        //
        //  We assert that for each substring, the actual components are the same as the expected components
        //  The order in which the components appear is irrelevant.
        
        nakedComponents.forEach {
            
            XCTAssertEqual(Set($0.actual), Set($0.expected), "Components found in the string do not match expected components.")
        }
        
        // 4 - Check that components always appear in the same order in all substrings.
        //
        //  a. For each substring, we map each component to its index in the reference components list.
        //
        //      e.g. if the actual components are
        //
        //          ["toto', 'tata"]
        //
        //      and the reference components are
        //
        //          ["tata", "toto"]
        //
        //      then we have
        //
        //          [1, 0]
        //
        //  b. Given that all components sets have the same number of items, if components appear in the same order in each set,
        //     then the index lists are all the same for each substring.
        
        let indicesForEachSet = nakedComponents.map { (actual, expected) in
            
            return actual.mapIndicesIn(expected)
        }
        
        XCTAssertTrue(indicesForEachSet.areAllTheSame, "Order of appearance of components differ in two or more sequences.")
    }
}


extension String {
    
    
    /// Returns whether the string matches a regex pattern at least once.
    ///
    /// - Parameter pattern: The regex pattern.
    ///
    /// - Returns: `true` if the string matches the regex pattern at least once.
    ///
    func matches(_ pattern: String) -> Bool {

        let inputRange = NSRange(self.startIndex..<self.endIndex, in: self)

        let regex = try! NSRegularExpression(pattern: pattern, options: [])

        return regex.matches(in: self, options: [], range: inputRange).count > 0
    }
    
    
    /// Applies a regex on the string and returns the substrings that correspond
    /// to the capturing groups for each match.
    ///
    /// In the example below, the regex produces two matches: "to-ta" and "ta-ti".
    /// The first match captures "to-ta", "to" and "ta", and the second match
    /// captures "ta-ti", "ta" and "ti".
    /// ```
    /// "toto-tata-titi".substringsForCapturingGroups(from: "((t[oai])-(t[oai]))")
    /// // ["to-ta", "to", "ta", "ta-ti", "ta", "ti"]
    /// ```
    ///
    /// - Parameter pattern: The regex pattern to use to extract portions of the
    ///             string.
    ///
    /// - Returns: The portions of the string that match the capturing groups in
    ///            the pattern, in order.
    ///
    func substringsForCapturingGroups(definedBy pattern: String) -> [Substring] {
        
        var results: [Substring] = []
        
        let inputRange = NSRange(self.startIndex..<self.endIndex, in: self)
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        for match in regex.matches(in: self, options: [], range: inputRange) {
        
            for i in 1..<match.numberOfRanges {
                
                let nsrange = match.range(at: i)
                let range = Range(nsrange, in: self)!
                
                results.append(self[range])
            }
        }
        
        return results
    }
}


extension Array where Element: Equatable {
    
    
    /// Returns an array that contains the indices of each element of the array
    /// in another array.
    ///
    /// In the example below, the method returns [2, 1] because the first
    /// element of the input array, i.e. "foo", appears at index 2 in the
    /// reference array, while the second element, i.e. "bar", appears at index 1.
    /// ```
    /// ["foo", "bar"].mapIndicesIn(["baz", "bar", "foo"])
    /// // [2, 1]
    /// ```
    ///
    /// - Complexity: O(*n***m*), where n is the length of the input array, and
    ///               m is the length of the reference array.
    ///
    /// - Parameter other: The reference array. This array must contain at least
    ///             one occurence of each element of the input array.
    ///
    /// - Returns: An array that contains the indices of each element of the
    ///            input array in the reference array.
    ///
    func mapIndicesIn(_ other: Array) -> [Array.Index]
    {
        return map { other.firstIndex(of: $0)! }
    }
}


extension Array where Element: Hashable {
    
    
    /// Returns whether all the elements are equal.
    ///
    var areAllTheSame: Bool {
        
        return Set(self).count == 1
    }
}
