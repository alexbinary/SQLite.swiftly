
import Foundation



/// A statement that inserts data into a table in a SQLite database.
///
/// This class provides convenience methods that facilitate the execution of
/// queries of the form `INSERT INTO <table>;`.
///
public class InsertStatement: Statement {
    
    
    /// A description of the table the statement inserts data into.
    ///
    private let tableDescription: TableDescription
    
    
    /// The query that was used to compile the statement.
    ///
    private let insertQuery: InsertQuery
    
    
    /// Creates a new statement.
    ///
    /// - Parameter tableDescription: The table the statement should insert data
    ///             into.
    ///
    /// - Parameter connection: The connection to use to compile the query.
    ///
    init(insertingIntoTable tableDescription: TableDescription, on connection: Connection) {
        
        self.tableDescription = tableDescription
        self.insertQuery = InsertQuery(insertingIntoTable: tableDescription)
        
        super.init(compiling: insertQuery, on: connection)
    }
}


extension InsertStatement {
    
    
    /// Inserts values into the table.
    ///
    /// - Parameter columnValues: A dictionary that contain the value to insert
    ///             in each column.
    ///
    public func insert(_ columnValues: [ColumnDescription: QueryParameterValue]) {
        
        var parameterValues: [QueryParameter: QueryParameterValue] = [:]
        
        for (column, parameter) in insertQuery.parameters {
        
            guard let value = columnValues[column] else {
                
                fatalError("[InsertStatement] Missing value for column: \(column). Trying to insert into table: \(tableDescription.name), values: \(columnValues)")
            }
            
            parameterValues[parameter] = value
        }
        
        _ = runThroughCompletion(with: parameterValues)
    }
}
