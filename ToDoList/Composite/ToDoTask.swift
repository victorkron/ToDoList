//
//  ToDoTask.swift
//  ToDoList
//
//  Created by Карим Руабхи on 28.05.2022.
//

import UIKit

class ToDoTask: Task {
    var name: String
    var subtasks: [Task]
    var sublevelID: String
    var parentSublevel: String?
    
    init (name: String, subtasks: [Task] = [], sublevelID: String, parentSublevel: String) {
        self.name = name
        self.subtasks = subtasks
        self.sublevelID = sublevelID
        self.parentSublevel = parentSublevel
    }
    
    init (name: String, subtasks: [Task] = [], sublevelID: String) {
        self.name = name
        self.subtasks = subtasks
        self.sublevelID = sublevelID
    }
}
