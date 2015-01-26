//
//  TasksViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

class TasksViewController : UIViewController {
    
    var timer: NSTimer! = NSTimer()
    
    @IBOutlet var loadingIndicator : UIActivityIndicatorView! = nil
    @IBOutlet var loading : UILabel!
    @IBOutlet var nextViewButton: UIBarButtonItem!
    @IBOutlet var previousViewButton: UIBarButtonItem!
    
    private var popoverContent: TaskPopoverController!
    private var popOverVC: UIPopoverController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewTask(sender: UIBarButtonItem) {
        if(self.popoverContent == nil) {
            self.popoverContent = TaskPopoverController(nibName: "TaskPopoverController", bundle: nil)
        }
        
        if(self.popOverVC == nil) {
            self.popOverVC = UIPopoverController(contentViewController: popoverContent)
        }
        
        self.popOverVC.presentPopoverFromBarButtonItem(sender, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
    }
}
    