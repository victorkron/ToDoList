//
//  TasksData.swift
//  ToDoList
//
//  Created by Карим Руабхи on 28.05.2022.
//

import Foundation

class TasksData: Codable {
    
    var tasksData: [String: [String : [TaskData]]]
    
    static let shared = TasksData()
    private init() {
        tasksData = [:]
    }
    
    func clear() {
        tasksData = [:]
    }
}

class TaskData: Codable {
    let name: String
    let parentTaskSublevelID: String?
    let amountSubtasks: Int
    
    init(name: String, amountSubtasks: Int, parentTaskSublevelID: String?) {
        self.name = name
        self.amountSubtasks = amountSubtasks
        self.parentTaskSublevelID = parentTaskSublevelID
    }
}

