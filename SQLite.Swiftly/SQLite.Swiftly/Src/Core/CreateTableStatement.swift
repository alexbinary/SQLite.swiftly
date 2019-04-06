
import Foundation



/// A statement that creates a table in a SQLite database.
///
/// This class provides convenience methods that facilitate the execution of
/// queries of the form `CREATE TABLE (<columns>);`.
///
public class CreateTableStatement: Statement {
    
    
    /// A description of the table the statement creates.
    ///
    private let tableDescription: TableDescription
    
    
    /// The query that was used to compile the statement.
    ///
    private let createTableQuery: CreateTableQuery
    
    
    /// Creates a new statement.
    ///
    /// - Parameter tableDescription: The table the statement should create.
    /// - Parameter connection: The connection to use to compile the query.
    ///
    public init(creatingTable tableDescription: TableDescription, on: Connection) {
        
        self.tableDescription = tableDescription
        self.createTableQuery = CreateTableQuery(creatingTable: tableDescription)
        
        super.init(compiling: createTableQuery, on: on)
    }
}


extension CreateTableStatement {
    

    /// Executes the statement.
    ///
    func run() {
        
        _ = runThroughCompletion()
    }
}
