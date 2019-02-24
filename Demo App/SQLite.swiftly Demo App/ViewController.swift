//
//  ViewController.swift
//  SQLite.swiftly Demo App
//
//  Created by Alexandre Bintz on 23/02/2019.
//  Copyright © 2019 Alexandre Bintz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        run()
    }

    func run() {
        
        let applicationSupportUrl = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let folderUrl = applicationSupportUrl.appendingPathComponent(Bundle.main.bundleIdentifier!)
        
        let databaseUrl = folderUrl.appendingPathComponent("db.sqlite")
        
        print(databaseUrl.path)
        
        writeToDatabase(url: databaseUrl)
        readFromDatabase(url: databaseUrl)
    }
    
    func writeToDatabase(url: URL) {
        
        let connection = SQLite_Connection(toDatabaseAt: url)
    }
    
    func readFromDatabase(url: URL) {
        
    }
}

