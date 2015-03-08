//
//  TasksViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

class TasksViewController : UIViewController, UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var tasksTableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var noDataLabel: UILabel!
    private var didRemoveLast: Bool!
    
    private var popOverNavController: UINavigationController!
    private var popoverContent: TaskPopoverViewController!
    private var popOverVC: UIPopoverController!
    
    private var taskDetailVC: TaskEditViewController!
    
    private var newTaskObject: Task!
    private var taskManager: TaskManager!
    private var taskList: [Task]!
    private var indexPendingDelete: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newTaskObject = nil
        taskManager = TaskManager()
        taskList = []
        didRemoveLast = false
        
        tasksTableView.registerNib(UINib(nibName: "TaskViewCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        tasksTableView.dataSource = self
        tasksTableView.delegate = self
        tasksTableView.allowsMultipleSelectionDuringEditing = false
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = gmOrangeColor;
        self.refreshControl.tintColor = UIColor.whiteColor();
        self.refreshControl.addTarget(taskManager, action: Selector("getAllTasksRequest"), forControlEvents: UIControlEvents.ValueChanged)
        self.tasksTableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentViewController?.title = "Tasks"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InvalidTaskResponse", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedTaskList:", name:"TaskListUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedTaskAdd:", name: "TaskAdded", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(!Reachability.isConnectedToNetwork()) {
            SCLAlertView().showNotice("No Network Connection",
                subTitle: "You don't appear to be connected to the Internet. Please check your connection.",
                duration: 6)
        } else {
            taskManager.getAllTasksRequest()
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification Handlers
    
    func receivedNetworkError(notification: NSNotification) {
        /*SCLAlertView().showError("Network Error",
        subTitle: "Oops something went wrong",
        closeButtonTitle: "Dismiss")*/
        self.reloadTaskData()
    }
    
    func receivedInternalServerError(notification: NSNotification) {
        //stopLoading()
        let reason = getUserInfoValueForKey(notification.userInfo, "reason")
        let message = getUserInfoValueForKey(notification.userInfo, "message")
        SCLAlertView().showWarning("Internal Server Error",
            subTitle:  reason + " - " + message, closeButtonTitle: "Dismiss")
        self.reloadTaskData()
    }
    
    func receivedTaskList(notification: NSNotification) {
        let taskDictionary = notification.userInfo as Dictionary<String,Task>
        self.taskList = []
        
        for task in taskDictionary.values {
            self.taskList.append(task)
        }
        
        self.reloadTaskData()
    }
    
    func receivedTaskAdd(notification: NSNotification) {
        let resultDic = notification.userInfo as Dictionary<String, Bool>
        let result: Bool = resultDic["success"]!
        
        if result {
            self.refreshControl.beginRefreshing()
        } else {
            SCLAlertView().showWarning("Task Create Failed", subTitle: "An unknown error occured", closeButtonTitle: "Dismiss")
        }
    }
    
    func reloadTaskData() {
        self.tasksTableView.reloadData()
        
        if(self.refreshControl != nil) {
            var formatter = NSDateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
            let title: String = String(format: "Last update: %@", formatter.stringFromDate(NSDate()))
            var dictionary: Dictionary = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            var attributedString: NSAttributedString = NSAttributedString(string: title, attributes: dictionary)
            self.refreshControl.attributedTitle = attributedString
            
            self.refreshControl.endRefreshing()
        }
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
            taskManager.sendNewTaskRequest(self.newTaskObject)
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
        
        
        var longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("longPressTaskCell:"))
        longPress.minimumPressDuration = 2.0
        cell.contentView.addGestureRecognizer(longPress)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (self.taskList.count > 0 || didRemoveLast == true) {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
            
            if(noDataLabel != nil) {
                tableView.backgroundView = nil
                noDataLabel = nil
            }
            
            return 1;
        }
        
        noDataLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        noDataLabel.text = "No Tasks found. Pull down to refresh or press the + to create one."
        noDataLabel.textColor = gmOrangeColor
        noDataLabel.numberOfLines = 0
        noDataLabel.textAlignment = NSTextAlignment.Center
        noDataLabel.font = gmFontQuoteLarge
        noDataLabel.sizeToFit()
        
        tableView.backgroundView = noDataLabel
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        return 0;
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
        if(self.taskDetailVC == nil) {
            self.taskDetailVC = TaskEditViewController(nibName: "TaskEditViewController", bundle: nil)
        }
        
        self.taskDetailVC.setTask(cell.getTaskObject())
        self.navigationController?.pushViewController(taskDetailVC, animated: true)

    }
    
    func longPressTaskCell(sender: UILongPressGestureRecognizer) {
        
        if(sender.state == UIGestureRecognizerState.Ended) {
            let point: CGPoint = sender.locationInView(self.tasksTableView)
            let indexPath: NSIndexPath = self.tasksTableView.indexPathForRowAtPoint(point)!
            //var tableViewCell: TaskViewCell = self.tasksTableView.cellForRowAtIndexPath(indexPath) as TaskViewCell!
            
            indexPendingDelete = indexPath
            
            let actionSheet = UIActionSheet(title: "Are you sure you want to delete this Task?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Delete Task")
            actionSheet.addButtonWithTitle("Cancel")
            actionSheet.actionSheetStyle = .BlackOpaque
            actionSheet.showInView(self.view)
        }
    }
    
    // MARK: UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if(buttonIndex == 0 && indexPendingDelete != nil) {
            var index: Int = indexPendingDelete.row
            taskManager.deleteTaskRequest(taskList[index])
            
            if(index == 0) {
                didRemoveLast = true
            } else {
                didRemoveLast = false
            }
            
            self.tasksTableView.beginUpdates()
            taskList.removeAtIndex(index)
            self.tasksTableView.deleteRowsAtIndexPaths([indexPendingDelete], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tasksTableView.endUpdates()
        }
        
        indexPendingDelete = nil
        actionSheet.dismissWithClickedButtonIndex(buttonIndex, animated: true)
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if(buttonIndex == 0 && didRemoveLast == true) {
            didRemoveLast = false
            self.tasksTableView.reloadData()
        }
    }
}
    