
import Foundation



/// A SQL query that inserts data into a table in a SQLite database.
///
/// This type represents queries of the form
/// `INSERT INTO <table> (<columns>) VALUES(<values>);`.
///
/// The query uses query parameters as placeholders for the actual values. You
/// can access the query parameters that are used in the query along with the
/// table column they correspond to with the `parameters` property.
///
struct InsertQuery: Query {
    
    
    /// A description of the table the query should insert data into.
    ///
    let tableDescription: TableDescription
    
    
    /// The query parameters used in the query.
    ///
    /// This property returns a dictionary that indicates the parameter used to
    /// represent the value that should be inserted into each column.
    ///
    let parameters: [ColumnDescription: SQLite_QueryParameter]
    
   
    /// Creates a new query.
    ///
    /// - Parameter tableDescription: A description of the table the query
    ///             should insert data into.
    ///
    init(insertingIntoTable tableDescription: TableDescription) {
        
        self.tableDescription = tableDescription
        
        var parameters: [ColumnDescription: SQLite_QueryParameter] = [:]
        
        for column in tableDescription.columns {
            
            parameters[column] = SQLite_QueryParameter(name: ":\(column.name)")
        }
        
        self.parameters = parameters
    }
    
    
    /// The SQL code that implements the query.
    ///
    var sqlString: String {
        
        let columns = Array(tableDescription.columns)
        let parameters = columns.map { self.parameters[$0]! }
        
        return [
            
            "INSERT INTO \(tableDescription.name) (",
            columns.map { $0.name } .joined(separator: ", "),
            ") VALUES(",
            parameters.map { $0.name } .joined(separator: ", "),
            ");"
            
        ].joined()
    }
}
