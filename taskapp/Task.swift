//
//  Task.swift
//  taskapp
//
//  Created by user on 2023/03/20.
//

import RealmSwift

class Task: Object{

    @objc dynamic var id = 0

    @objc dynamic var title = ""
    
    @objc dynamic var contents = ""

    @objc dynamic var date = Date()

    @objc dynamic var category = ""

    override static func primaryKey() -> String?{
        return "id"
    }
}
