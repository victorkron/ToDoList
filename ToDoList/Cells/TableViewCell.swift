//
//  TableViewCell.swift
//  ToDoList
//
//  Created by Карим Руабхи on 28.05.2022.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var taskNameLabel: UILabel!
    @IBOutlet var subtasksCountLabel: UILabel!
    
    func config(name: String, subtask count: Int) {
        taskNameLabel.text = name
        subtasksCountLabel.text = "Количество подзадач: \(count)"
    }
    
}
