//
//  TaskEditViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-03-05.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class TaskEditViewController: UIViewController {

    private var task: Task!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTask(task: Task) {
        self.task = task
    }

}
