//
//  TasksViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

class TasksViewController : UIViewController, UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tasksTableView: UITableView!
    
    // TODO: Replace with UIAlertController
    private let alert = UIAlertView()
    
    private var popOverNavController: UINavigationController!
    private var popoverContent: TaskPopoverViewController!
    private var popOverVC: UIPopoverController!
    
    private var newTaskObject: Task!
    private var taskManager: TaskManager!
    private var taskList: [Task]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newTaskObject = nil
        taskManager = TaskManager()
        taskList = []
        
        tasksTableView.registerNib(UINib(nibName: "TaskViewCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        tasksTableView.dataSource = self
        tasksTableView.delegate = self
        tasksTableView.allowsMultipleSelectionDuringEditing = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInvalidTaskResponse:", name:"InvalidTaskResponse", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedTaskList:", name:"TaskListUpdated", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        taskManager.getAllTasksRequest()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification Handlers
    
    func receivedNetworkError(notification: NSNotification) {
        //stopLoading()
        alert.title = "Network Error"
        alert.message = "Please check your network connection"
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func receivedInternalServerError(notification: NSNotification) {
        //stopLoading()
        alert.title = getUserInfoValueForKey(notification.userInfo, "reason")
        alert.message = getUserInfoValueForKey(notification.userInfo, "message")
        alert.addButtonWithTitle("Dismiss")
        alert.show()
    }
    
    func receivedInvalidTaskResponse(notification: NSNotification) {
        alert.title = getUserInfoValueForKey(notification.userInfo, "reason")
        alert.message = getUserInfoValueForKey(notification.userInfo, "message")
        alert.addButtonWithTitle("Dismiss")
        alert.show()
    }
    
    func receivedTaskList(notification: NSNotification) {
        let taskDictionary = notification.userInfo as Dictionary<String,Task>
        self.taskList = []
        
        for task in taskDictionary.values {
            self.taskList.append(task)
        }
        
        self.tasksTableView.reloadData()
    }
    
    @IBAction func addNewTask(sender: UIBarButtonItem) {
        if(self.popoverContent == nil) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.popoverContent = TaskPopoverViewController(nibName: "TaskPopoverViewController", bundle: nil)
        }
        
        if(self.popOverNavController == nil) {
            self.popOverNavController = UINavigationController(rootViewController: popoverContent)
            
            var saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("saveTaskTapped:"))
            
            var cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("cancelTaskTapped:"))
            
            self.popoverContent.navigationItem.title = "New Task"
            self.popoverContent.navigationItem.rightBarButtonItem = saveButton
            self.popoverContent.navigationItem.leftBarButtonItem = cancelButton
        }
        
        if(self.popOverVC == nil) {
            self.popOverVC = UIPopoverController(contentViewController: popOverNavController)
        }
        
        self.popOverVC.popoverContentSize = CGSize(width: 400, height: 550)
        
        self.popOverVC.delegate = self
        self.popOverVC.presentPopoverFromBarButtonItem(sender, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
    }
    
    @IBAction func cancelTaskTapped(sender: UIBarButtonItem) {
        if(self.popOverVC != nil) {
            // Clear all fields here?
            // Or overwrite defualt values on viewDidLoad?
            self.popOverVC.dismissPopoverAnimated(true)
        }
    }
    
    @IBAction func saveTaskTapped(sender: UIBarButtonItem) {
        if(self.popoverContent != nil) {
            self.newTaskObject = self.popoverContent.getDisplayTask()
        }
        
        if(self.popOverVC != nil) {
            self.popOverVC.dismissPopoverAnimated(true)
        }
        
        if(self.newTaskObject != nil) {
            // TODO: Save task to server ?
        }
    }
    
    // MARK: - UIPopOverController Delegate
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TaskViewCell = tableView.dequeueReusableCellWithIdentifier("taskCell") as TaskViewCell!
        
        cell.backgroundColor = UIColor.clearColor()
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        
        cell.setTaskObject(taskList[indexPath.row])
        
        /*
        var longpress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("taskCellLongPress:"))
        longpress.minimumPressDuration = 2
        cell.contentView.addGestureRecognizer(longpress)*/
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete) {
            
        }
    }
    
    //MARK: - UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as TaskViewCell!
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // TODO: Prompt action sheet for edit or delete

    }
    

    /*
    func taskCellLongPress(sender: UILongPressGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.Ended) {
            let point: CGPoint = sender.locationInView(self.tasksTableView)
            let indexPath: NSIndexPath = self.tasksTableView.indexPathForRowAtPoint(point)!
            var tableViewCell: TaskViewCell = self.tasksTableView.cellForRowAtIndexPath(indexPath) as TaskViewCell!
            
            
        }
    }*/
}
    