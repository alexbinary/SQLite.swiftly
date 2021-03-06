
import Foundation



/// A SQL query.
///
public protocol Query {
 
    
    /// The SQL string that expresses the query.
    ///
    var sqlString: String { get }
}
