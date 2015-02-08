//
//  TaskPopoverViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-27.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

protocol popOverNavDelegate {
    func saveName(value: String)
    func saveType(value: String)
    func saveRepeat(value: Dictionary<Int,Bool>)
    func saveAlert(value: String) // TODO: Probably need sound file and such as well
    func saveNotes(value: String)
    func saveCustom(value: String)
}

class TaskPopoverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, popOverNavDelegate {
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var taskFieldsTableView: UITableView!
    
    var displayTask: Task!
    var nameVC: TaskNameViewController!
    var typeVC: TaskTypeViewController!
    var repeatVC: TaskRepeatTypeViewController!
    var alertVC: TaskAlertTypeViewController!
    var notesVC: TaskNotesViewController!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var now: NSDate = NSDate()
        displayTask = Task(id: "temp", title: "New Task", creation: now, nextAlert: now.addMinutesToDate(1), type: TaskType.CHORE, alertTime: now.toTimeString(), soundFileName: UNKNOWN, notes: "")
        displayTask.setDaysOfTheWeek(false, tue: false, wed: false, thu: false, fri: false, sat: false, sun: false)
        
        NotificationManager.sharedInstance.scheduleNotificationForTask(displayTask)
        
        taskFieldsTableView.registerNib(UINib(nibName: "PopoverViewCell", bundle: nil), forCellReuseIdentifier: "taskPopoverCell")
        taskFieldsTableView.dataSource = self
        taskFieldsTableView.delegate = self
        taskFieldsTableView.scrollEnabled = false
        timePicker.minimumDate = NSDate()
        timePicker.maximumDate = NSDate().addMonthsToDate(12)
        
        var backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDisplayTask() -> Task {
        return self.displayTask
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PopoverViewCell = tableView.dequeueReusableCellWithIdentifier("taskPopoverCell") as PopoverViewCell!
        
        cell.backgroundColor = UIColor.clearColor()
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        
        switch(indexPath.row) {
        case 0:
            cell.setTitle("Name")
            cell.setValue(displayTask.title)
            break
        case 1:
            cell.setTitle("Type")
            cell.setValue(displayTask.type.rawValue)
            break
        case 2:
            cell.setTitle("Repeat")
            cell.setValue(displayTask.daysOfWeekToDisplayString())
            break
        case 3:
            cell.setTitle("Alert")
            cell.setValue(displayTask.displaySoundEnabledFlag())
            break
        case 4:
            cell.setTitle("Custom")
            cell.setValue("")
            break
        case 5:
            cell.setTitle("Notes")
            cell.setValue(displayTask.notesDisplayPreview())
            break
        default:
            cell.setTitle("")
            cell.setValue("")
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    //MARK: - UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as PopoverViewCell!
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch(cell.getTitle()) {
        case "Name":
            if(self.nameVC == nil) {
                self.nameVC = TaskNameViewController(nibName: "TaskNameViewController", bundle: nil)
                self.nameVC.delegate = self
            }
            self.navigationController?.pushViewController(self.nameVC, animated: true)
            break
        case "Type":
            if(self.typeVC == nil) {
                self.typeVC = TaskTypeViewController(nibName: "TaskTypeViewController", bundle: nil)
                self.typeVC.delegate = self
            }
            self.typeVC.setSelection(displayTask.type.rawValue)
            self.navigationController?.pushViewController(self.typeVC, animated: true)
            break
        case "Repeat":
            if(self.repeatVC == nil) {
                self.repeatVC = TaskRepeatTypeViewController(nibName: "TaskRepeatTypeViewController", bundle: nil)
                self.repeatVC.delegate = self
            }
            self.repeatVC.setCellSelectionList(self.displayTask.daysOfWeekToDictionary())
            self.navigationController?.pushViewController(self.repeatVC, animated: true)
            break
        case "Alert":
            if(self.alertVC == nil) {
                self.alertVC = TaskAlertTypeViewController(nibName: "TaskAlertTypeViewController", bundle: nil)
                self.alertVC.delegate = self
            }
            self.alertVC.setSelectedItem(self.displayTask.soundFileName)
            self.navigationController?.pushViewController(self.alertVC, animated: true)
            return
        case "Notes":
            if(self.notesVC == nil) {
                self.notesVC = TaskNotesViewController(nibName: "TaskNotesViewController", bundle: nil)
                self.notesVC.delegate = self
            }
            self.notesVC.setNotes(self.displayTask.notes)
            self.navigationController?.pushViewController(self.notesVC, animated: true)
            break
        case "Custom":
            return
        default:
            return
        }
    }
    
    //MARK: - Custom Popover Nav delegate
    
    func saveName(value: String) {
        if(value != "") {
            self.displayTask.title = value
        }
        taskFieldsTableView.reloadData()
    }
    
    // TODO: Change custom field based on the type selected
    func saveType(value: String) {
        if(value != "") {
            let type: TaskType = TaskType.typeFromString(value)
            if(type != TaskType.UNKNOWN) {
                self.displayTask.type = type
            }
        }
        taskFieldsTableView.reloadData()
    }
    
    func saveRepeat(value: Dictionary<Int,Bool>) {
        if(value.count == 7) {
            self.displayTask.daysOfWeekFromDictionary(value)
        }
        taskFieldsTableView.reloadData()
    }
    
    func saveAlert(value: String) {
        self.displayTask.soundFileName = value
        taskFieldsTableView.reloadData()
    }
    
    func saveNotes(value: String) {
        self.displayTask.notes = value
        taskFieldsTableView.reloadData()
    }
    
    func saveCustom(value: String) {
        
    }
}
