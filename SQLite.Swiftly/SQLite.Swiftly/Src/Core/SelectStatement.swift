
import Foundation



/// A statement that reads data from a table in a SQLite database.
///
/// This class provides convenience methods that facilitate the execution of
/// queries of the form `SELECT * FROM <table>;`.
///
public class SelectStatement: Statement {
    
    
    /// A description of the table the statement reads from.
    ///
    private let tableDescription: TableDescription
    
    
    /// The query that was used to compile the statement.
    ///
    private let selectQuery: SelectQuery
    
    
    /// Creates a new statement.
    ///
    /// - Parameter tableDescription: The table the statement reads from.
    /// - Parameter connection: The connection to use to compile the query.
    ///
    init(selectingFromTable tableDescription: TableDescription, on: Connection) {
        
        self.tableDescription = tableDescription
        self.selectQuery = SelectQuery(selectingFromTable: tableDescription)
        
        super.init(compiling: selectQuery, on: on)
    }
}


extension SelectStatement {
    
    
    /// Read all result rows returned by the statement.
    ///
    /// - Returns: The rows. Values are read according to the type of the
    ///            corresponding column declared in the table description.
    ///
    public func readAllRows() -> [TableRow] {
        
        let rows = runThroughCompletion(readingResultRowsWith: tableDescription)
        
        return rows
    }
}
