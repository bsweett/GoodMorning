//
//  TaskNameViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-27.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class TaskNameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    var delegate: popOverNavDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Name"
        
        self.taskNameField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.taskNameField.selected = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        if(taskNameField.text.isTaskName()) {
            delegate?.saveName(taskNameField.text)
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayErrorForTime(text: String, time: Double) {
        
        if(self.errorLabel.text == "") {
            self.errorLabel.fadeIn(duration: 2.0, completion: {
                (finished: Bool) -> Void in
                self.errorLabel.text = text
                self.errorLabel.fadeOut(delay: time, completion: {
                (finished: Bool) -> Void in
                        self.errorLabel.text = ""
                })
            })
        }
    }
    
    // MARK: - UITextField Delegate
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        
        if (textField == taskNameField && taskNameField.text.isTaskName()) {
            self.navigationController?.popViewControllerAnimated(true)
            return true
        }
        
        displayErrorForTime("Name must be 1 to 255 characters", time: 5.0)
        return false
    }

}
