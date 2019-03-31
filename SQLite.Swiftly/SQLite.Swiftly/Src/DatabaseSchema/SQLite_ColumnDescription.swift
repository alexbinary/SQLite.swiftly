
import Foundation



/// A description of a column in a SQLite database table.
///
public class SQLite_ColumnDescription {
    
    
    /// The column's name.
    ///
    let name: String
    
    
    /// The column's type.
    ///
    let type: SQLite_ColumnType
    
    
    /// Whether the column can contain the value NULL.
    ///
    let nullable: Bool
    
    
    /// Creates a new description of a table column.
    ///
    /// - Parameter name: The column's name.
    /// - Parameter type: The column's type.
    /// - Parameter nullable: Whether the column can contain the value NULL.
    ///
    public init(name: String, type: SQLite_ColumnType, nullable: Bool) {
        
        self.name = name
        self.type = type
        self.nullable = nullable
    }
}


extension SQLite_ColumnDescription: SQLite_SQLRepresentable {
    
    
    /// The SQL string that represents the column.
    ///
    /// This property returns the SQL fragment that can be used in
    /// "CREATE TABLE" queries and other type of SQL queries where a table
    /// column needs to be expressed.
    ///
    /// Example: `name CHAR(6) NOT NULL`
    ///
    public var sqlRepresentation: String {
        
        return [
            
            name,
            type.sqlRepresentation,
            nullable ? "NULL" : "NOT NULL",
            
        ].joined(separator: " ")
    }
}


extension SQLite_ColumnDescription: Equatable {

    // Implementing the `Equatable` protocol allows implementation of the
    // `Hashable` protocol.

    public static func == (lhs: SQLite_ColumnDescription, rhs: SQLite_ColumnDescription) -> Bool {

        return lhs.name == rhs.name
            && lhs.type == rhs.type
            && lhs.nullable == rhs.nullable
    }
}


extension SQLite_ColumnDescription: Hashable {
    
    // Implementing the `Hashable` protocol allows use of the type for elements
    // in sets and for keys in dictionaries.
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(nullable)
    }
}
