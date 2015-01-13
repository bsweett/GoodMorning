//
//  InstallViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-18.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class InstallViewController : UIViewController, UITextFieldDelegate {
    
    let manager: InstallManager = InstallManager()
    let errorColor : UIColor = UIColor( red: 176, green: 35, blue: 14, alpha: 1.0 )
    let defualtColor : UIColor = UIColor( red: 0.5, green: 0.5, blue:0, alpha: 1.0 )
    
    let alert = UIAlertView()
    
    @IBOutlet var nameErrorLabel : UILabel!
    @IBOutlet var emailErrorLabel : UILabel!
    @IBOutlet var nameField : UITextField!
    @IBOutlet var emailField : UITextField!
    @IBOutlet var submitButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        nameField.delegate = self
        emailField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInstallComplete:", name:"InstallComplete", object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        resetErrorLabelsAndColorsForField(nameField)
        resetErrorLabelsAndColorsForField(emailField)
        
        if(!Reachability.isConnectedToNetwork()) {
            alert.title = "Network Connection"
            alert.message = "You don't appear to be connected to the Internet. Please check your connection."
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func submitButtonAction(sender:UIButton!) {
        
        setUIElementsEnabled(false)
        
        let nickname = nameField.text
        let email = emailField.text
        var valid: Bool = true
        
        if(email.isEmpty || !email.isEmail()) {
            setErrorLabelForField(emailField)
            valid = false
            
        }
        
        if(nickname.isEmpty || !nickname.isName()) {
            setErrorLabelForField(nameField)
            valid = false
            
        }
        
        if(valid) {
            manager.sendInstallRequestForUser(nickname, email: email)
            
        } else {
            setUIElementsEnabled(true)
            
        }
    }
    
    private func setUIElementsEnabled(enabled: Bool) {
        submitButton.enabled = enabled
        nameField.enabled = enabled
        emailField.enabled = enabled
    }
    
    private func setErrorLabelForField(textField: UITextField) {
        
        textField.layer.borderColor = errorColor.CGColor
        
        if(textField == nameField) {
            nameErrorLabel.text = "Invalid Name"
            
        } else if (textField == emailField) {
            emailErrorLabel.text = "Invalid Email"
            
        }
        
    }
    
    private func resetErrorLabelsAndColorsForField(textField: UITextField) {
        
        textField.layer.borderColor = defualtColor.CGColor
        
        if(textField == nameField) {
            nameErrorLabel.text = ""
            
        } else if (textField == emailField) {
            emailErrorLabel.text = ""
            
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        let text = textField.text
        
        if(textField == nameField) {
            if(text.isEmpty || !text.isName()) {
                setErrorLabelForField(textField)
                
            } else {
                resetErrorLabelsAndColorsForField(textField)
                
            }
            
        } else if(textField == emailField) {
            if(text.isEmpty || !text.isEmail()) {
                setErrorLabelForField(textField)
                
            } else {
                resetErrorLabelsAndColorsForField(textField)
                
            }
            
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        
        if (textField == nameField) {
            emailField.becomeFirstResponder()
            
        } else if(textField == emailField) {
            emailField.resignFirstResponder()
            
        }
        
        return true
    }
    
    func receivedNetworkError(notification: NSNotification) {
        alert.title = "Network Error"
        alert.message = "Please check your network connection"
        alert.addButtonWithTitle("Ok")
        alert.show()
        
        setUIElementsEnabled(true)
    }
    
    func receivedInternalServerError(notification: NSNotification) {
        alert.title = "Internal Server Error"
        alert.message = getUserInfoMessage(notification.userInfo)
        alert.addButtonWithTitle("Dismiss")
        alert.show()
        
        setUIElementsEnabled(true)
    }
    
    func receivedInstallComplete(notification: NSNotification) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isInstalled");
        NSUserDefaults.standardUserDefaults().synchronize()
        
        performSegueWithIdentifier("InstallationComplete", sender: self)
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        // For now do nothing
    }
}