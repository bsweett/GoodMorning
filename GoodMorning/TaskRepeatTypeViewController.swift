//
//  TaskRepeatTypeViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-01.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class TaskRepeatTypeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var repeatTable: UITableView!
    
    var cellSelectionList: Dictionary<Int, Bool> = [:]
    
    var delegate: popOverNavDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Repeat"
        
        self.repeatTable.dataSource = self
        self.repeatTable.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.repeatTable.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if(self.cellSelectionList.count == 7) {
            delegate?.saveRepeat(self.cellSelectionList)
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setCellSelectionList(dictionary: Dictionary<Int,Bool>) {
        self.cellSelectionList = dictionary
    }
    
    // MARK: - UITableView Datasource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "dayCell")
        
        cell.backgroundColor = UIColor.clearColor()
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        cell.tintColor = gmOrangeColor
        
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel?.font = gmFontNormal
        
        switch(indexPath.row) {
        case 0:
            cell.textLabel?.text = "Monday"
            break
        case 1:
            cell.textLabel?.text = "Tuesday"
            break
        case 2:
            cell.textLabel?.text = "Wednesday"
            break
        case 3:
            cell.textLabel?.text = "Thursday"
            break
        case 4:
            cell.textLabel?.text = "Friday"
            break
        case 5:
            cell.textLabel?.text = "Saturday"
            break
        case 6:
            cell.textLabel?.text = "Sunday"
            break
        default:
            break
        }
        
        let selected: Bool = (self.cellSelectionList[indexPath.row])!
        
        if(selected) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    // MARK : - UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selected: Bool = (self.cellSelectionList[indexPath.row])!
        
        if(selected) {
            self.cellSelectionList[indexPath.row] = false
        } else {
            self.cellSelectionList[indexPath.row] = true
        }
        
        self.repeatTable.reloadData()
    }
}
