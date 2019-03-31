
import Foundation



/// The set of possible data types for columns in a SQLite database table.
///
public enum ColumnType: Hashable {
    
    
    /// A column that contains a small amount of text.
    ///
    /// The associated value indicates the maximum number of characters the
    /// column can contain.
    ///
    case char(size: Int)
    
    
    /// A column that contains a boolean value.
    ///
    case bool
}


extension ColumnType {
    
    
    /// The SQL string that represents the column type.
    ///
    /// This property returns the SQL fragment that can be used in
    /// "CREATE TABLE" queries and other type of SQL queries where a column type
    /// needs to be expressed.
    ///
    public var sqlRepresentation: String {
        
        switch (self) {
            
        case .bool:
            
            return "BOOL"
            
        case .char(let size):
            
            return "CHAR(\(size))"
        }
    }
}
