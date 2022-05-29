//
//  Task.swift
//  ToDoList
//
//  Created by Карим Руабхи on 28.05.2022.
//

import Foundation

protocol Task {
    var name: String { get set }
    var sublevelID: String { get set }
    var subtasks: [Task] { get set }
    var parentSublevel: String? { get set }
}

