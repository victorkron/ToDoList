//
//  TasksViewController.swift
//  ToDoList
//
//  Created by Карим Руабхи on 28.05.2022.
//

import UIKit
import SwiftUI

class TasksViewController: UIViewController {
    
    private var barButton: UIBarButtonItem? = nil
    private var button: UIButton? = nil
    private let tableView = UITableView()
    private var sublevel: Int = 0
    private let caretaker = TasksCaretaker()
    
    var currentControllerTasks: [Task] = [] {
        didSet {
            tableView.reloadData()
            saveDataToUserDefaults()
        }
    }
    
    var selectedTaskNumber: Int?
    
    // MARK: - Constructors
    
    init(tasks: [Task]) {
        self.currentControllerTasks = tasks
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        loadDataFromUserDefaults()
//        UserDefaults.standard.removeObject(forKey: "myTasks")
        tableView.register(
            UINib(nibName: "TableViewCell", bundle: nil),
            forCellReuseIdentifier: "TableViewCell"
        )
        self.title = "Sublevel \(sublevel)"
        
//        setTableView()
//        setBarButton()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        switch sublevel % 3 {
        case 0:
            self.navigationController?.navigationBar.backgroundColor = UIColor.customGreen
        case 1:
            self.navigationController?.navigationBar.backgroundColor = UIColor.customOrange
        case 2:
            self.navigationController?.navigationBar.backgroundColor = UIColor.customPink
        default:
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        setBarButton()
        setTableView()
    }
    
    
    // MARK: - Actions
    
    @objc private func addTask(sender: UIBarButtonItem) {
        presentAlert()
    }
    
    
    // MARK: - Private Function
    
    private func saveDataToUserDefaults() {
        var tasksData: [TaskData] = []
        
        var parentTaskSublevelID: String = ""
        
        if self.sublevel != 0 {
            if let parentVC = self.navigationController?.viewControllers[self.sublevel - 1] as? TasksViewController,
               let parentTaskNumber = parentVC.selectedTaskNumber {
                parentTaskSublevelID  = "\(parentTaskNumber)"
            }
            
        } else {
            parentTaskSublevelID = "undef"
        }
        
        currentControllerTasks.forEach { task in
            var taskData: TaskData
            if  self.sublevel != 0,
                let parentSublevel = task.parentSublevel    {
                
                taskData = TaskData(
                    name: task.name,
                    amountSubtasks: task.subtasks.count,
                    parentTaskSublevelID: parentSublevel
                )
            } else {
                
                taskData = TaskData(name: task.name, amountSubtasks: task.subtasks.count, parentTaskSublevelID: "undef")
                
                
            }
            tasksData.append(taskData)
        }
        
        
        if TasksData.shared.tasksData["\(self.sublevel)"] == nil {
            TasksData.shared.tasksData["\(self.sublevel)"] = [:]
            if TasksData.shared.tasksData["\(self.sublevel)"]?[parentTaskSublevelID] == nil {
                TasksData.shared.tasksData["\(self.sublevel)"]?[parentTaskSublevelID] = []
            }
            TasksData.shared.tasksData["\(self.sublevel)"]?[parentTaskSublevelID] = tasksData
        } else {
            if TasksData.shared.tasksData["\(self.sublevel)"]?[parentTaskSublevelID] == nil {
                TasksData.shared.tasksData["\(self.sublevel)"]?[parentTaskSublevelID] = []
            }
            TasksData.shared.tasksData["\(self.sublevel)"]?[parentTaskSublevelID] = tasksData
        }
        
        
        self.caretaker.save(tasks: TasksData.shared.tasksData)
    }
    
    private func loadDataFromUserDefaults() {
        if sublevel == 0 {
            TasksData.shared.tasksData = caretaker.receiveRecords()
            var itemsOfLevels: [String: [Task]] = [:]
            
            for (levelKey, _) in TasksData.shared.tasksData {
                guard let dict = TasksData.shared.tasksData[levelKey] else { continue }
                for (patentIdKey, _) in dict {
                    dict[patentIdKey]?.forEach { taskData in
                        let task = ToDoTask(
                            name: taskData.name,
                            subtasks: [],
                            sublevelID: "\(levelKey)",
                            parentSublevel: taskData.parentTaskSublevelID ?? ""
                        )
                        if itemsOfLevels[levelKey] == nil {
                            itemsOfLevels[levelKey] = [task]
                        } else {
                            itemsOfLevels[levelKey]?.append(task)
                        }
                    }
                }
            }
            
            currentControllerTasks = vspom(array: itemsOfLevels["0"] ?? [], key: 0, dict: itemsOfLevels)
        }
    }
    
    private func vspom(array: [Task], key: Int, dict: [String: [Task]]) -> [Task] {
        var arr = array
        for mainItemNumber in 0..<arr.count {
            guard let dataArr = TasksData.shared.tasksData["\(key + 1)"]?["\(mainItemNumber)"] else { continue }
            var taskArr: [Task] = []
            
            if dataArr.count != 0 {
                dataArr.forEach { subItem in
                    let task = ToDoTask(
                        name: subItem.name,
                        subtasks: [],
                        sublevelID: "\(taskArr.count)",
                        parentSublevel: "\(mainItemNumber)"
                    )
                    taskArr.append(task)
                }
                
                arr[mainItemNumber].subtasks = vspom(array: taskArr, key: key + 1, dict: dict)
            }
        }
        return arr
    }
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        tableView.rowHeight = 80
        self.view.addSubview(tableView)
    }
    
    private func setBarButton() {
        barButton = UIBarButtonItem(
            image: UIImage(named: "customAdd"),
            style: .plain,
            target: self,
            action: #selector(addTask(sender:))
        )
        navigationController?.navigationBar.topItem?.setRightBarButton(barButton, animated: true)
    }
    
    private func presentAlert() {
        let alertController = UIAlertController(
            title: "Add Task",
            message: "Write a keyword for the task",
            preferredStyle: .alert
        )
        alertController.addTextField(configurationHandler: nil)
        let action = UIAlertAction(title: "Add", style: .default) { action in
            guard
                let text = alertController.textFields?[0].text,
                text != ""
            else { return }
            
            
            var parentTaskSublevelID: String = ""
            
            if self.sublevel != 0 {
                if let parentVC = self.navigationController?.viewControllers[self.sublevel - 1] as? TasksViewController,
                   let parentTaskNumber = parentVC.selectedTaskNumber {
                    parentTaskSublevelID  = parentVC.currentControllerTasks[parentTaskNumber].sublevelID
                }
                
            } else {
                parentTaskSublevelID = "undef"
            }
            
            let task = ToDoTask(name: text, subtasks: [], sublevelID: "\(self.currentControllerTasks.count)", parentSublevel: parentTaskSublevelID)
            
            self.currentControllerTasks.append(task)
            
            if  self.sublevel != 0,
                let parentVC = self.navigationController?.viewControllers[self.sublevel - 1] as? TasksViewController,
                let parentTaskNumber = parentVC.selectedTaskNumber {
                parentVC.currentControllerTasks[parentTaskNumber].subtasks = self.currentControllerTasks
            }
        }
        
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    private func tasksOf() {
        guard let selectedTaskNumber = selectedTaskNumber else {
            return
        }

        let secondViewController: TasksViewController = TasksViewController(tasks: currentControllerTasks[selectedTaskNumber].subtasks)
        secondViewController.sublevel = sublevel + 1
        
        navigationController?.pushViewController(secondViewController, animated: true)
    }
    
}


extension TasksViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentControllerTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
                .dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell
        else { return UITableViewCell() }
        
        let task = currentControllerTasks[indexPath.row]
        cell.config(name: task.name, subtask: task.subtasks.count)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTaskNumber = indexPath.row
        tasksOf()
    }
}



class MyTasks {
    var tasks: [Task] = []
}
