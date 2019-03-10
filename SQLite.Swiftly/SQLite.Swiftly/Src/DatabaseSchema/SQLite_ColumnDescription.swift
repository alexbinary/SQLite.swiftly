
import Foundation



/// A description of a column in a SQLite database table.
///
public class SQLite_ColumnDescription {
    
    
    /// The column's name.
    ///
    public let name: String
    
    
    /// The column's type.
    ///
    public let type: SQLite_ColumnType
    
    
    /// Whether the column can contain the value NULL.
    ///
    public let nullable: Bool
    
    
    /// Creates a new description.
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
    
    
    public static func == (lhs: SQLite_ColumnDescription, rhs: SQLite_ColumnDescription) -> Bool {

        return lhs.name == rhs.name
            && lhs.type == rhs.type
            && lhs.nullable == rhs.nullable
    }
}


extension SQLite_ColumnDescription: Hashable {
    
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(nullable)
    }
}
