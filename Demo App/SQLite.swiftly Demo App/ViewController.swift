//
//  ViewController.swift
//  SQLite.swiftly Demo App
//
//  Created by Alexandre Bintz on 23/02/2019.
//  Copyright © 2019 Alexandre Bintz. All rights reserved.
//

import UIKit
import SQLite_Swiftly

class ViewController: UIViewController {

    
    let column1 = SQLite_ColumnDescription(name: "c1", type: .char(size: 255), nullable: false)
    let column2 = SQLite_ColumnDescription(name: "c2", type: .char(size: 255), nullable: false)
    
    lazy var table = SQLite_TableDescription(name: "demoTable", columns: [column1, column2])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        run()
    }

    func run() {
        
        let applicationSupportUrl = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let folderUrl = applicationSupportUrl.appendingPathComponent(Bundle.main.bundleIdentifier!)
        
        try! FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        
        let databaseUrl = folderUrl.appendingPathComponent("db.sqlite")
        
        try? FileManager.default.removeItem(at: databaseUrl)
        
        print(databaseUrl.path)
        
        writeToDatabase(url: databaseUrl)
        readFromDatabase(url: databaseUrl)
    }
    
    func writeToDatabase(url: URL) {
        
        let connection = SQLite_Connection(toDatabaseAt: url)
        
        connection.createTable(describedBy: table)
        
        let statement = SQLite_InsertStatement(insertingIntoTable: table, connection: connection)
        
        statement.insert([
            column1: "hello",
            column2: "world",
        ])
    }
    
    func readFromDatabase(url: URL) {
        
        let connection = SQLite_Connection(toDatabaseAt: url)
        
        let statement = SQLite_SelectStatement(selectingFromTable: table, connection: connection)
        
        for row in statement.readAllRows() {
            
            for (column, value) in row {
            
                print("\(column.name) : \(String(describing: value))")
            }
        }
    }
}

