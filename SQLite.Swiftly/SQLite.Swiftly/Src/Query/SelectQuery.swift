
import Foundation



/// A SQL query that selects data from a table in a SQLite database.
///
/// This type represents queries of the form `SELECT * FROM <table>;`.
///
struct SelectQuery: Query {
    
    
    /// A description of the table the query should select data from.
    ///
    let tableDescription: TableDescription
    
    
    /// Creates a new query.
    ///
    /// - Parameter tableDescription: The table the query should select data
    ///             from.
    ///
    init(selectingFromTable tableDescription: TableDescription) {
        
        self.tableDescription = tableDescription
    }
    
    
    /// The SQL code that implements the query.
    ///
    var sqlString: String {
        
        return "SELECT * FROM \(tableDescription.name);"
    }
}
