
import Foundation



/// A description of a SQLite database table.
///
public class SQLite_TableDescription {
   
    
    /// The table's name.
    ///
    let name: String
    
    
    /// The table's columns.
    ///
    let columns: Set<ColumnDescription>
    
    
    /// An array that contains the names of the columns.
    ///
    /// This property is provided to offer better performance when we need
    /// to access the columns names multiple times.
    ///
    private lazy var columnNames: Set<String> = Set(columns.map { $0.name })
    
    
    /// The columns indexed by their name.
    ///
    /// This property is provided to offer better performance when we need
    /// to access columns by name multiple times.
    ///
    private lazy var columnsByName: [String: ColumnDescription] = {
        
        var columnsByName: [String: ColumnDescription] = [:]
       
        columns.forEach { column in
         
            columnsByName[column.name] = column
        }
        
        return columnsByName
    }()
    
    
    /// Creates a new description of a table.
    ///
    /// - Parameter name: The table's name.
    /// - Parameter columns: The table's columns.
    ///
    public init(name: String, columns: Set<ColumnDescription>) {
        
        self.name = name
        self.columns = columns
    }
}


extension SQLite_TableDescription {

    
    /// Returns a column from its name.
    ///
    /// - Parameter name: The column's name.
    ///
    /// - Returns: The column whose name matches the provided name, or `nil` if
    ///            the table has no column whose name matches the provided name.
    ///
    /// - Complexity: O(1)
    ///
    func column(withName name: String) -> ColumnDescription? {
        
        return columnsByName[name]
    }
    
    
    /// Returns whether the table has a column with a given name.
    ///
    /// - Parameter name: The column's name.
    ///
    /// - Returns: `true` if the table has a column whose name matches the
    ///            provided name, `false` otherwise.
    ///
    /// - Complexity: O(1)
    ///
    func hasColumn(withName name: String) -> Bool {
        
        return columnNames.contains(name)
    }
}
