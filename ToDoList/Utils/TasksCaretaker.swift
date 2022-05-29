//
//  TasksCaretaker.swift
//  ToDoList
//
//  Created by Карим Руабхи on 28.05.2022.
//

import Foundation

class TasksCaretaker {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let key = "myTasks"
    
    func save(tasks: [String: [String : [TaskData]]]) {
        do {
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print(error)
        }
    }
    
    func receiveRecords() -> [String: [String : [TaskData]]] {
        guard
            let data = UserDefaults.standard.value(forKey: key) as? Data
        else { return [:] }
        
        do {
            return try decoder.decode([String: [String : [TaskData]]].self, from: data)
        } catch {
            print(error)
            return [:]
        }
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
