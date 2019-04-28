
import Foundation



public class Client {

    
    public private(set) var databaseLocation: URL
    
    
    var connection: Connection?
    
    
    public init(forDatabaseAt url: URL) {
        
        databaseLocation = url
    }
    
    
    var isConnectionOpen: Bool {
        
        return connection != nil
    }
    
    
    func openConnectionIfNeeded() {
        
        if !isConnectionOpen {
            
            openConnection()
        }
    }
    
    
    func openConnection() {
        
        connection = try! Connection(toExistingDatabaseAt: databaseLocation)
    }
    
    
    func closeConnection() {
        
        connection = nil
    }
    
    
    var anticipatedActivityLevel: ActivityLevel = .mostlyIdle
    
    
    public func createTable(describedBy tableDescription: TableDescription) {
        
        runOnConnection { connection in
            
            connection.createTable(describedBy: tableDescription)
        }
    }
    
    
    func runOnConnection(_ block: (Connection) -> Void) {
        
        openConnectionIfNeeded()
        
        guard let connection = connection else {
            
            fatalError("connection was not opened")
        }
        
        block(connection)
        
        if anticipatedActivityLevel == .mostlyIdle {
            
            closeConnection()
        }
    }
}



enum ActivityLevel {
    
    case active
    case mostlyIdle
}
